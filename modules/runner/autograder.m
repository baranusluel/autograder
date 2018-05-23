%% autograder: Main responsibility for running the autograder
%
% autograder is called by the Autograder class - it is responsible for running the
% actual steps needed to grade students automatically.
%
%%% Remarks
%
% Main is the entry point for the Autograder. Main will handle any
% exceptions, and will always clean up afdatater itself - the user's folder
% will not be changed!
%
% Documentation is available. Please go the the autograder's website, at
%
% <https://github.gatech.edu/pages/CS1371/autograder Documentation>
%
% This function should not be called directly, though its help manual
% may be useful
%
%%% Exceptions
%
% This is guarunteed to never throw an exception; instead, exceptions are reported through the GUI
%
%%% Unit Tests
%
% Unfortunately, there are no "Unit Tests" for this function
%
function autograder(app)
    % Implementation Notes:
    %
    % Main() will provide initial checking, and set up all necessary
    % processes and environment settings:
    %
    % *Startup*
    %
    % * Start the Parallel Pool
    % * Create the SENTINEL file; assign to the File class
    % * Apply the factory default path, and remove the user's MATLAB path
    % * Create a temporary folder, and copy the student and solution files
    % there. If they're zips, deal with accordingly
    % * Ensure figures don't become visible
    %
    % *Cleanup*
    %
    % * Shut down the parallel pool
    % * Close and delete the SENTINEL file
    % * Reapply the path of the original user
    % * Copy any necessary data back from temp folder (?)
    % * Reapply user's settings for figures

    % Parse inputs

    % Show the app. After it's done (uiresume), we'll extract necessary
    % info and then change to updating. If it's cancelled, we'll exit
    % gracefully.

    %%% Constants
    % add to path
    % The number of students to wait between before redrawing the histogram
    DRAW_INTERVAL = 10;
    % The label for inspecting students
    INSPECT_LABEL = 'Inspect the Students';
    % The label for continuing on
    CONTINUE_LABEL = 'Continue';
    
    settings.userPath = {path(), userpath()};
    % change name of overloaded files
    overloaders = fileparts(mfilename('fullpath'));
    files = dir([overloaders filesep 'overloader' filesep '*.txt']);
    for f = 1:numel(files)
        [~, name, ~] = fileparts(files(f).name);
        movefile([files(f).folder filesep files(f).name], ...
            [files(f).folder filesep name '.m']);
    end
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    clear Student;
    Student.resetPath();

    % start up application
    settings.app = app;
    try
        if app.isDebug
            logger = Logger(pwd);
        else
            logger = Logger();
        end
    catch e
        if app.isDebug
            keyboard;
        else
            alert(app, e);
            return;
        end
    end
    settings.logger = logger;
    % Start up parallel pool
    progress = uiprogressdlg(app.UIFigure, 'Title', 'Autograder Progress', ...
        'Message', 'Starting Parallel Pool', 'Cancelable', 'on', ...
        'ShowPercentage', true, 'Indeterminate', 'on');
    Logger.log('Starting up parallel pool');
    settings.progress = progress;
    evalc('gcp');
    app.UIFigure.Visible = 'off';
    app.UIFigure.Visible = 'on';
    if progress.CancelRequested
        return;
    end
    progress.Message = 'Setting Up Environment';
    Logger.log('Setting up new directory');
    % Get temporary directory
    settings.workingDir = [tempname filesep];
    mkdir(settings.workingDir);
    settings.userDir = cd(settings.workingDir);
    % Create SENTINEL file
    Logger.log('Creating Sentinel');
    fid = fopen(File.SENTINEL, 'wt');
    fwrite(fid, 'SENTINEL');
    fclose(fid);

    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    
    % close all files and plots
    wait(parfevalOnAll(@()(fclose('all')), 0));
    wait(parfevalOnAll(@()(delete(findall(0, 'type', 'figure'))), 0));
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            Logger.log('Exchanging refresh token for access token');
            token = refresh2access(app.driveToken);
            Logger.log('Starting download of solution archive from Google Drive');
            downloadFromDrive(app.driveFolderId, token, ...
                [pwd filesep 'Solutions'], app.driveKey, progress);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    else
        % unzip the archive
        progress.Indeterminate = 'on';
        progress.Message = 'Unzipping Rubric';
        Logger.log('Unzipping Solution Archive');
        try
            unzipArchive(app.solutionArchivePath, [pwd filesep 'Solutions']);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end

    % Generate solutions
    try
        orig = cd('Solutions');
        Logger.log('Generating Solutions');
        solutions = generateSolutions(app.isResubmission, progress);
        cd(orig);
        app.solutions = solutions;
    catch e
        % Display to user that we failed
        if app.isDebug
            keyboard;
        else
            cd(orig);
            alert(app, e);
            return;
        end
    end
    setupRecs(solutions);
    wait(parfevalOnAll(@setupRecs, 0, solutions));
    % For submission, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Students');
    if app.HomeworkChoice.Value == 1
        % downloading. We should create new Students folder and download
        % there.
        try
            downloadFromCanvas(app.canvasCourseId, app.canvasHomeworkId, ...
                app.canvasToken, [pwd filesep 'Students'], progress);
        catch e
            % alert in some way and return
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    else
        progress.Message = 'Unzipping Student Archive';
        progress.Indeterminate = 'on';
        % unzip the archive
        try
            unzipArchive(app.homeworkArchivePath, [pwd filesep 'Students']);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end
    % Generate students
    try
        Logger.log('Generating Students');
        students = generateStudents([pwd filesep 'Students'], progress);
        app.students = students;
    catch e
        if app.isDebug
            keyboard;
        else
            alert(app, e);
            return;
        end
    end

    % Create Plot
    plotter = uifigure('Name', 'Grade Report');
    ax = uiaxes(plotter);
    ax.Position = [10 10 550 400]; % as suggested in example on MATLAB ref page
    title(ax, 'Histogram of Student Grades');
    xlabel(ax, 'Grade');
    ylabel(ax, 'Number of Students');
    h = histogram(ax);
    totalPoints = [solutions.testCases];
    totalPoints = sum([totalPoints.points]);
    h.BinEdges = 0:10:max([totalPoints (ceil(totalPoints / 10) * 10)]);
    h.BinLimits = [0 h.BinEdges(end)];
    h.Data = zeros(1, numel(students)) - 1;
    ax.YLim = [0 numel(students)];
    ax.XLim = [0 h.BinLimits(end)];

    plotter.Visible = 'on';

    drawnow;
    
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Student Grading Progress';
    Logger.log('Starting student assessment');
    for s = 1:numel(students)
        student = students(s);
        progress.Message = sprintf('Assessing Student %s', student.name);
        try
            Logger.log(sprintf('Assessing Student %s (%s)', student.name, student.id));
            student.assess();
        catch e
            if app.isDebug
                keyboard;
            else
                alert(e);
                return;
            end
        end
        progress.Value = min([progress.Value + 1/numel(students), 1]);
        h.Data(s) = student.grade;
        if mod(s, DRAW_INTERVAL) == 0
            drawnow;
        end
        if progress.CancelRequested
            e = MException('AUTOGRADER:userCancelled', 'User Cancelled Operation');
            alert(e);
            return;
        end
    end
    
    drawnow;
    
    % Before we do anything else, examine the grades. There should be a
    % good distribution - if not, ask the user
    
    % What exactly "is" a good distribution? No idea. For now, we will flag
    % if:
    %   Nobody got 100
    %   Nobody got > 90
    %   Nobody got a 0
    %   All values are either 0 or 100
    %   All values are the same
    if ~any(h.Data > (.9 * totalPoints))
        msg = 'No student scored above 90%.';
    elseif ~any(h.Data == totalPoints)
        msg = 'No student scored a 100%.';
    elseif ~any(h.Data == 0)
        msg = sprintf('Every student scored above 0%; the minimum was %0.2f.', ...
            min(data));
    elseif all(h.Data == totalPoints | h.Data == 0)
        msg = 'All students scored either a 0% or a 100%';
    else
        % we have passed... for now.
        msg = '';
    end
    if ~isempty(msg)
        msg = [msg ' Would you like to inspect the students, or continue?'];
        selection = uiconfirm(app.UIFigure, msg, 'Autograder', ...
            'Options', {INSPECT_LABEL, CONTINUE_LABEL}, ...
            'DefaultOption', 1, 'Icon', 'warning', 'CancelOption', 2);
        if strcmp(selection, INSPECT_LABEL)
            stop = true;
        else
            stop = false;
        end
    else
        stop = false;
    end
    if stop
        keyboard;
    end
    
    if app.AnalyzeForCheating.Value
        try
            progress.Message = 'Reading Student Submissions';
            progress.Indeterminate = 'on';
            progress.Cancelable = 'off';

            txts = cell(1, numel(students));
            for s = numel(students):-1:1
                workers(s) = parfeval(@getText, 1, students(s).problemPaths);
            end

            progress.Value = 0;
            progress.Indeterminate = 'off';
            progress.Cancelable = 'on';
            num = numel(workers);

            while ~all([workers.Read])
                if progress.CancelRequested
                    cancel(workers);
                    return;
                end
                [idx, txt] = workers.fetchNext();
                txts{idx} = txt;
                progress.Value = min([progress.Value + 1/num, 1]);
            end

            wait(parfevalOnAll(@getScores, 0, [], txts));
            progress.Value = 0;
            progress.Message = 'Analyzing Submissions... This will take a while';
            % for each student, we need to compare to all other students.
            scores = cell(1, numel(students));
            for s1 = numel(students):-1:1
                workers(s1) = parfeval(@getScores, 1, s1);
            end

            num = numel(workers);

            while ~all([workers.Read])
                [idx, score] = workers.fetchNext();
                scores{idx} = score;
                progress.Value = min([progress.Value + 1/num, 1]);
                if progress.CancelRequested
                    cancel(workers);
                    return;
                end
            end

            % generate Report
            progress.Message = 'Generating Report';
            progress.Indeterminate = 'on';
            progress.Cancelable = 'off';

            % move resources
            recSource = [fileparts(mfilename('fullpath')) filesep 'resources'];
            mkdir('resources');
            copyfile(recSource, [pwd filesep 'resources']);
            CheatDetector(students, solutions, scores, settings.workingDir);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end
    % If the user requested uploading, do it

    if app.UploadToCanvas.Value
        try
            Logger.log('Starting upload of student grades');
            uploadToCanvas(students, app.canvasCourseId, ...
                app.canvasHomeworkId, app.canvasToken, progress);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end
    if app.UploadToServer.Value
        Logger.log('Starting upload of student files');
        if app.isResubmission
            name = sprintf('homework%02d_resubmission', app.homeworkNum);
        else
            name = sprintf('homework%02d', app.homeworkNum);
        end
        try
            uploadToServer(students, app.serverUsername, app.serverPassword, ...
                name, progress);
        catch e
            if app.isDebug
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end

    % if they want the output, do it
    if ~isempty(app.localOutputPath)
        progress.Indeterminate = 'on';
        progress.Message = 'Saving Output';
        % save canvas info in path
        % copy csv, then change accordingly
        % move student folders to output path
        Logger.log('Starting copy of local information');
        copyfile(settings.workingDir, app.localOutputPath);
    end
end

function alert(app, e)
    uialert(app.UIFigure, sprintf('Exception %s: "%s" encountered', ...
        e.identifier, e.message), 'Autograder Error');
    app.exception = e;
end

function cleanup(settings)
    if isvalid(settings.progress)
        settings.progress.Message = 'Cleaning Up';
        settings.progress.Indeterminate = 'on';
        settings.progress.Cancelable = 'off';
    end
    % Cleanup
    Logger.log('Deleting Sentinel file');
    delete(File.SENTINEL);
    % Restore user's path
    Logger.log('Restoring User Path settings');
    path(settings.userPath{1}, '');
    if ~isempty(settings.userPath{2})
        userpath(settings.userPath{2});
    end
    % change name of overloaded files
    overloaders = fileparts(mfilename('fullpath'));
    files = dir([overloaders filesep 'overloader' filesep '*.m']);
    for f = 1:numel(files)
        [~, name, ~] = fileparts(files(f).name);
        movefile([files(f).folder filesep files(f).name], ...
            [files(f).folder filesep name '.txt']);
    end

    % cd to user's dir
    cd(settings.userDir);
    Logger.log('Removing Working Directory');
    % Delete our working directory - UNLESS cheat detection is on!
    if ~settings.app.AnalyzeForCheating.Value
        [~] = rmdir(settings.workingDir, 's');
    end
    if isvalid(settings.progress)
        close(settings.progress);
    end
    settings.logger.delete();
end

function setupRecs(solutions)
    recs = Student.resources;
    recs.Problems = solutions;
end

function scores = getScores(varargin)
    persistent students;
    if nargin == 2
        students = varargin{2};
        return;
    elseif nargin == 1
        s1 = varargin{1};
    end
    subs = students{s1};
    % students is cell array; each cell is a cell array of size p, and each
    % entry there is the contents of a single problem and its hash
    
    % for each student, for each problem, calculate the jaccard index
    scores = cell(1, numel(students));
    for s2 = 1:numel(scores)
        txts = students{s2};
        if s1 == s2
            scores{s2} = zeros(1, numel(txts));
        else
            for p = numel(txts):-1:1
                % get jaccard index
                if ~isempty(subs{p}{1}) && ~isempty(txts{p}{1})
                    % compare
                    if subs{p}{2} == txts{p}{2}
                        scores{s2}(p) = Inf;
                    else
                        [rank1, rank2] = jaccardIndex(subs{p}{1}, txts{p}{1});
                        scores{s2}(p) = sum(rank1 == rank2) / length(rank1);
                    end
                else
                    scores{s2}(p) = 0;
                end
            end
        end
    end
end

function problemTxt = getText(problemPaths)
    for p = numel(problemPaths):-1:1
        if isempty(problemPaths{p})
            problemTxt{p} = cell(1, 2);
        else
            fid = fopen(problemPaths{p}, 'rt');
            code = char(fread(fid)');
            fclose(fid);
            tree = mtree(code);
            tmp = strsplit(code, newline, 'CollapseDelimiters', false);
            % remove comments
            problemTxt{p}{1} = ...
                strjoin(tmp(unique(tree.getlastexecutableline)), newline);
            problemTxt{p}{2} = java.lang.String(code).hashCode;
        end
    end
end