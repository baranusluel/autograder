%% downloadFromCanvas: Download the submission archive from Canvas
%
% downloadFromCanvas will download the given assignment to be parsed by the
% autograder, for the given students
%
% downloadFromCanvas(S, P, B) will use the student and submission
% information in S, the token in T, and the path in P to download and save
% the homework submission in an autograder-ready format in the path
% specified. Additionally, it will update the progress bar B.
%
%%% Remarks
%
% The first input of the function should be a vector of structures
% representing students, where each has a name, login_id, and submission
% field. The value of the submission field is another structure that
% can have an attachments field.
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
%   % Assume the parameters are correct: S, P, B
%   downloadFromCanvas(S, P, B);
%
%   In path P, the student folders are all saved, along with a `grades.csv`
function downloadFromCanvas(students, path, progress)
    origPath = cd(path);
    cleaner = onCleanup(@()(cd(origPath)));
    numStudents = numel(students);
    names = cell(1, numStudents);
    ids = cell(1, numStudents);
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
        if isfield(students(s).submission, 'attachments') && ~isempty(students(s).submission.attachments)
            workers{s} = saveFiles(students(s).submission.attachments, students(s).login_id);
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
        fid = fopen([path filesep attachment.filename], 'w');
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