%% downloadFromCanvas: Download the ZIP archive from Canvas
%
% downloadFromCanvas will download the given assignment to be parsed by the
% autograder
%
% downloadFromCanvas(C, A, T, P, B) will use the course ID in C, the assignment
% ID in A, the token in T, and the path in P to download and save the homework submission
% in an autograder-ready format in the path specified. Additionally, it
% will update the progress bar B.
%
%%% Remarks
%
% This is used when instead of pre-downloading a ZIP archive, the user
% wants the autograder to directly download the student's submissions.
%
%%% Exceptions
%
% This will throw a generic AUTOGRADER:networking:connectionError exception
% if something goes wrong with the connection
%
%%% Unit Tests
%
%   % Assume the parameters are correct: C, A, T, P, B
%   downloadFromCanvas(C, A, T, P, B);
%
%   In path P, the student folders are all saved, along with a `grades.csv`
function downloadFromCanvas(courseId, assignmentId, token, path, progress)
    subs = getSubmissions(courseId, assignmentId, token, progress);
    origPath = cd(path);
    cleaner = onCleanup(@()(cd(origPath)));
    % for each user, get GT Username, create folder, then inside that
    % folder, download submission
    numStudents = numel(subs);
    names = cell(1, numStudents);
    ids = cell(1, numStudents);
    % get ids
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Fetching Student Information';
    for s = numStudents:-1:1
        workers(s) = parfeval(@getStudentInfo, 1, subs{s}.user_id, token);
    end
    while ~all([workers.Read])
        fetchNext(workers);
        progress.Value = min([progress.Value + 1/numStudents, 1]);
        drawnow;
        if progress.CancelRequested
            cancel(workers);
            e = MException('AUTOGRADER:networking:connectionError', ...
                'User cancelled operation');
            e.throw();
        end
    end
    students = fetchOutputs(workers);
    delete(workers);
    workers = cell(1, numStudents);
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Downloading Student Submissions';
    for s = numStudents:-1:1
        % create folder with name as login_id
        mkdir(students(s).login_id);
        names{s} = students(s).name;
        ids{s} = students(s).login_id;
        % for each attachment, download it here
        if isfield(subs{s}, 'attachments')
            workers{s} = saveFiles(subs{s}.attachments, students(s).login_id);
        end
    end
    workers = [workers{:}];
    workers([workers.ID] == -1) = [];
    numToSave = numel(workers);
    while ~all([workers.Read])
        fetchNext(workers);
        progress.Value = min([progress.Value + 1/numToSave, 1]);
        drawnow;
        if progress.CancelRequested
            cancel(workers);
            e = MException('AUTOGRADER:networking:connectionError', ...
                'User cancelled operation');
            e.throw();
        end
    end
    % write info.csv
    names = [names; ids]';
    names = join(names, '", "');
    names = ['"' strjoin(names, '"\n"'), '"'];
    fid = fopen('info.csv', 'wt');
    fwrite(fid, names);
    fclose(fid);
    cd(origPath);
end

function workers = saveFiles(attachments, loginId)
    for a = numel(attachments):-1:1
        workers(a) = parfeval(@saveFile, 0, attachments(a), [pwd filesep loginId]);
    end
end

function saveFile(attachment, path, attempt, reason)
    MAX_ATTEMPT_NUM = 10;
    if nargin > 2 && attempt > MAX_ATTEMPT_NUM
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
    try
        downloader = matlab.net.http.RequestMessage;
        data = downloader.send(attachment.url);
        fid = fopen([path filesep attachment.filename], 'wt');
        fwrite(fid, data.Body.Data);
        fclose(fid);
    catch reason
        if nargin > 2
            saveFile(attachment, path, attempt + 1, reason);
        else
            saveFile(attachment, path, 1, reason);
        end
    end
end

function subs = getSubmissions(courseId, assignmentId, token, progress)
    API = 'https://gatech.instructure.com/api/v1/courses/';
    DEFAULT_SUBMISSION_NUM = 1000;
    try
        progress.Indeterminate = 'on';
        progress.Message = 'Fetching Student Submissions';
        request = matlab.net.http.RequestMessage;
        request.Header = matlab.net.http.HeaderField;
        request.Header.Name = 'Authorization';
        request.Header.Value = ['Bearer ' token];
        response = request.send([API courseId '/assignments/' assignmentId '/submissions/?per_page=100']);
        next = response.getFields('Link').parse({'link', 'rel'});
        % see if last was provided. If so, then we can prealloc (mostly)
        % precisely. Otherwise, just use DEFAULT_SUBMISSION_NUM
        last = next(strcmp([next.rel], "last"));
        next = next(strcmp([next.rel], "next"));
        if ~isempty(last)
            % get page: ?page=num&
            pgs = regexp(last.link, '(?<=\?page=)\d*', 'match');
            pgs = str2double(pgs{1});
            subs = cell(1, pgs-1);
            subs{1} = response.Body.Data';
            links = cell(1, pgs-1);
            links{1} = next.link.extractBetween('<', '>');
            for l = 2:pgs-1
                links{l} = regexprep(links{l-1}, '(?<=\?page=)\d*', '${num2str(1+str2double($0))}');
            end
            % for each link, fetch it's outputs and store it in subs
            for l = numel(links):-1:2
                workers(l-1) = parfeval(@fetchChunk, 1, links{l}, token);
            end
            progress.Indeterminate = 'off';
            progress.Value = 0;
            while ~all([workers.Read])
                [idx, sub] = fetchNext(workers);
                if progress.CancelRequested
                    cancel(workers);
                    throw(MException('AUTOGRADER:userCancellation', 'User Cancelled Operation'));
                end
                subs{idx + 1} = sub;
                progress.Value = min([progress.Value + 1/numel(workers), 1]);
            end
            subs = [subs{:}];
        else
            % Can't use our parfor; do the old fashioned way
            progress.Indeterminate = 'on';
            counter = 1;
            subs = cell(1, DEFAULT_SUBMISSION_NUM);
            subs(counter:(counter+numel(response.Body.Data)-1)) = response.Body.Data';
            counter = counter + numel(response.Body.Data);
            while ~isempty(next)
                if progress.CancelRequested
                    throw(MException('AUTOGRADER:userCancellation', 'User Cancelled Operation'));
                end
                % get the next batch
                % next.link is the link to ask for
                response = request.send(next.link.extractBetween('<', '>'));
                next = response.getFields('Link').parse({'link', 'rel'});
                next = next(strcmp([next.rel], "next"));
                subs(counter:(counter+numel(response.Body.Data)-1)) = response.Body.Data';
                counter = counter + numel(response.Body.Data);
            end
        end
        subs(cellfun(@isempty, subs)) = [];
        subs = subs(1:50);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
end

function info = getStudentInfo(userId, token)
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    opts.Timeout = 30;
    try
        info = webread([API '/users/' num2str(userId) '/profile/'], opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
end

function chunk = fetchChunk(link, token)
    request = matlab.net.http.RequestMessage;
    request.Header = matlab.net.http.HeaderField;
    request.Header.Name = 'Authorization';
    request.Header.Value = ['Bearer ' token];
    response = request.send(link);
    chunk = response.Body.Data';
end