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
    workers = cell(1, numStudents);
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Downloading Student Submissions';
    for s = numStudents:-1:1
        % create folder with name as login_id
        mkdir(students(s).login_id);
        names{s} = students(s).name;
        ids{s} = students(s).login_id;
        sections{s} = students(s).section;
        % for each attachment, download it here
        if isfield(students(s).submission, 'attachments') && ~isempty(students(s).submission.attachments)
            % create paths and links
            attachments = students(s).submission.attachments;
            for a = numel(attachments):-1:1
                paths(a) = string([pwd filesep students(s).login_id filesep attachments(a).filename]);
                urls(a) = string(attachments(a).url);
            end
            workers{s} = StudentDownloader(paths, urls);
        end
    end
    workers = [workers{:}];
    if ~isempty(workers)
        downloads = StudentDownloader.download(workers);
        tot = downloads.size();
        progress.Cancelable = 'off';
        while Download.numRemaining > 0
            progress.Value = min([1, (tot - Download.numRemaining) / tot]);
        end
        progress.Cancelable = 'on';
        downloads = downloads.toArray;
        mask = arrayfun(@(d)(d.isError), downloads);
    else
        mask = false;
    end
    % write info.csv
    names = [names; ids; sections]';
    names = join(names, '", "');
    names = ['"' strjoin(names, '"\n"'), '"'];
    fid = fopen('info.csv', 'wt');
    fwrite(fid, names);
    fclose(fid);
    cd(origPath);
    % check to make sure that none errored; if they did, alert!
    if any(mask)
        % we didn't make it; die
        [paths, names, exts] = arrayfun(@(d)(fileparts(char(d.getPath()))), downloads(mask), 'uni', false);
        [~, studs, ~] = cellfun(@fileparts, paths, 'uni', false);
        files = join([names exts], '');
        files = [strjoin(join([files studs], ' ('), ')\n') ')'];
        e = MException('AUTOGRADER:networking:connectionError', ...
            'We were unable to download the following files: \n%s', ...
            files);
        e.throw();
    end
end