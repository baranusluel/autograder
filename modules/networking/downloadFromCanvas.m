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
    sections = cell(1, numStudents);
    canvasIds = cell(1, numStudents);
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Downloading Student Submissions';
    progress.Cancelable = 'on';
    submissions = [];
    for s = numStudents:-1:1
        % create folder with name as login_id
        mkdir(students(s).login_id);
        names{s} = students(s).name;
        ids{s} = students(s).login_id;
        sections{s} = students(s).section;
        canvasIds{s} = students(s).id;
        % for each attachment, download it here
        if isfield(students(s).submission, 'attachments') && ~isempty(students(s).submission.attachments)
            % create paths and links
            attachments = students(s).submission.attachments;
            for a = numel(attachments):-1:1
                paths(a) = string([pwd filesep students(s).login_id filesep attachments(a).filename]);
                urls(a) = string(attachments(a).url);
            end
            submissions(s).paths = paths;
            submissions(s).urls = urls;
            % workers{s} = StudentDownloader(paths, urls);
        end
    end
    if ~isempty(submissions)
        for s = numel(submissions):-1:1
            workers(s) = parfeval(@saveFiles, 0, ...
                submissions(s).paths, ...
                submissions(s).urls);
        end
        while ~all([workers.Read])
            try
                fetchNext(workers);
            catch e
                workers.cancel;
                e.cause{1}.remotecause{1}.rethrow;
            end
            progress.Value = min(1, sum([workers.Read]) / numel(workers));
            if progress.CancelRequested
                workers.cancel;
                return;
            end
        end
    end
    % write info.csv
    names = [names; ids; sections; canvasIds]';
    names = join(names, '", "');
    names = ['"' strjoin(names, '"\n"'), '"'];
    fid = fopen('info.csv', 'wt');
    fwrite(fid, names);
    fclose(fid);
    cd(origPath);
end

function saveFiles(paths, links)
    opts = weboptions;
    opts.Timeout = 30;
    for f = 1:numel(links)
        websave(paths(f), links(f), opts);
    end
end