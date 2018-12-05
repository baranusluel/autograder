%% getCanvasStudents: Get list of students who submitted an assignment
%
% getCanvasStudents gets a struct array of student information for
% students who submitted a certain assignment
%
% getCanvasStudents(C, A, T, B) will use the course ID in C, the assignment
% ID in A and the token in T to get the list of students. Additionally, it
% will update the progress bar B.
%
%%% Remarks
%
% This is used when instead of pre-downloading a ZIP archive, the user
% wants the autograder to use submissions from Canvas.
%
% This function is called by StudentSelector when the submission source
% is specified by the user as Canvas.
%
% The outputs of this function are passed on to downloadFromCanvas once
% the autograder starts so that this data doesn't have to be downloaded
% multiple times.
%
%%% Exceptions
%
% This will throw a generic AUTOGRADER:networking:connectionError exception
% if something goes wrong with the connection
%
function students = getCanvasStudents(courseId, assignmentId, token, progress)
    subs = getSubmissions(courseId, assignmentId, token, progress);
    numStudents = numel(subs);
    % get info
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
    sections = getSectionInfo(courseId, token);
    sectionStudents = vertcat(sections.students)';
    inds = zeros(1, numel(sectionStudents));
    counter = 1;
    for i = 1:numel(sections)
        inds(counter:(counter+numel(sections(i).students)-1)) = i;
        counter = counter + numel(sections(i).students);
    end
    sectionStudentIds = [sectionStudents.id];
    for i = 1:numel(students)
        mask = str2double(students(i).id) == sectionStudentIds;
        if any(mask)
            students(i).section = sections(inds(mask)).name;
        else
            students(i).section = 'U';
        end
    end
    
    
    delete(workers);
    [students.submission] = deal(subs{:});
end

function subs = getSubmissions(courseId, assignmentId, token, progress)
    API = 'https://gatech.instructure.com/api/v1/courses/';
    DEFAULT_SUBMISSION_NUM = 10;
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
            if pgs == 1
                subs = response.Body.Data';
            else
                subs = cell(1, pgs);
                subs{1} = sanitizeData(response.Body.Data');
                links = cell(1, pgs - 1);
                links{1} = next.link.extractBetween('<', '>');
                for l = 2:pgs - 1
                    links{l} = regexprep(links{l-1}, '(?<=\?page=)\d*', '${num2str(1+str2double($0))}');
                end
                % for each link, fetch it's outputs and store it in subs
                for l = numel(links):-1:1
                    workers(l) = parfeval(@fetchChunk, 1, links{l}, token);
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
            end
        else
            % Can't use our parfor; do the old fashioned way
            progress.Indeterminate = 'on';
            counter = 2;
            subs = cell(1, DEFAULT_SUBMISSION_NUM);
            subs{1} = sanitizeData(response.Body.Data');
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
                subs{counter} = sanitizeData(response.Body.Data');
                counter = counter + 1;
            end
            subs(cellfun(@isempty, subs)) = [];
            subs = [subs{:}];
        end
        if ~iscell(subs)
            subs = num2cell(subs);
        end
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
end

function sections = getSectionInfo(courseId, token)
    API = 'https://gatech.instructure.com/api/v1/courses/%s/sections';
    
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    opts.Timeout = 30;
    % if we say 100 per page, get everything
    try
        sections = webread(sprintf(API, courseId), 'per_page', '100', 'include[]', 'students', opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
    % filter section - We just want the letter
    for s = 1:numel(sections)
        name = regexp(sections(s).name, '(?<=\d+\/\w+\/\d+\/)\w', 'match');
        sections(s).name = name{1};
    end
end

function info = getStudentInfo(userId, token)
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    opts.Timeout = 30;
    try
        info = webread([API '/users/' num2str(userId) '/profile/'], opts);
        info.login_id = matlab.lang.makeValidName(info.login_id);
        info.id = num2str(userId);
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
    chunk = sanitizeData(response.Body.Data');
end

function data = sanitizeData(data)
    if iscell(data)
        for c = 1:numel(data)
            if ~isfield(data{c}, 'attachments')
                data{c}.attachments = [];
            end
            data{c} = orderfields(data{c});
        end
        data = [data{:}];
    elseif isstruct(data) && ~isfield(data, 'attachments')
        data(1).attachments = [];
    end
end