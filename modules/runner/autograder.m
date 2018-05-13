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
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    clear Student;
    Student.resetPath();

    % start up application
    settings.app = app;
    try
        if app.isDebug
            logger = Logger(app.localDebugPath);
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
    % Make sure figure's don't show
    settings.figures = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');

    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            Logger.log('Exchanging refresh token for access token');
            token = refresh2access(app.driveToken);
            Logger.log('Starting download of solution archive from Google Drive');
            downloadFromDrive(app.driveFolderId, token, [pwd filesep 'Solutions'], app.driveKey, progress);
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

    % Grade students
    recs = Student.resources;
    recs.Problems = solutions;
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
    if stop == 1
        keyboard;
    end
    % If the user requested uploading, do it

    if app.UploadToCanvas.Value
        Logger.log('Starting upload of student grades');
        uploadToCanvas(students, app.canvasCourseId, ...
            app.canvasHomeworkId, app.canvasToken, progress);
    end
    if app.UploadToServer.Value
        Logger.log('Starting upload of student files');
        if app.isResubmission
            name = sprintf('homework%02d_resubmission', app.homeworkNum);
        else
            name = sprintf('homework%02d', app.homeworkNum);
        end
        uploadToServer(students, app.serverUsername, app.serverPassword, ...
            name, progress);
    end

    % if they want the output, do it
    if ~isempty(app.localOutputPath)
        progress.Indeterminate = 'on';
        progress.Message = 'Saving Output';
        % save canvas info in path
        % copy csv, then change accordingly
        % move student folders to output path
        Logger.log('Starting copy of local information');
        copyfile(pwd, app.localOutputPath);
    end
    if ~isempty(app.localDebugPath)
        % save MAT file
        progress.Indeterminate = 'on';
        progress.Message = 'Saving Debugger Information';
        Logger.log('Starting copy of debug information');
        copyfile(settings.workingDir, app.localDebugPath);
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

    % cd to user's dir
    cd(settings.userDir);
    Logger.log('Removing Working Directory');
    % Delete our working directory
    [~] = rmdir(settings.workingDir, 's');
    % Restore figure settings
    set(0, 'DefaultFigureVisible', settings.figures);
    % store debugging info
    app = settings.app;
    if isvalid(settings.progress)
        settings.progress.Message = 'Saving Output for Debugger...';
    end
    if ~isempty(app.localDebugPath)
        Logger.log('Saving Debug Information');
        % Don't compress - takes too long (and likely unnecessary)
        students = app.students; %#ok<NASGU>
        solutions = app.solutions; %#ok<NASGU>
        exception = app.exception; %#ok<NASGU>
        save([app.localDebugPath filesep 'autograder.mat'], ...
            'students', 'solutions', 'exception', '-v7.3', '-nocompression');
    end
    if isvalid(settings.progress)
        close(settings.progress);
    end
    settings.logger.delete();
end