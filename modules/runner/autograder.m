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
    % Start up parallel pool
    progress = uiprogressdlg(app.UIFigure, 'Title', 'Autograder Progress', ...
        'Message', 'Starting Parallel Pool', 'Cancelable', 'on', ...
        'ShowPercentage', true, 'Indeterminate', 'on');
    settings.progress = progress;
    evalc('gcp');
    app.UIFigure.Visible = 'off';
    app.UIFigure.Visible = 'on';
    if progress.CancelRequested
        return;
    end
    progress.Message = 'Setting Up Environment';
    % Get temporary directory
    settings.workingDir = [tempname filesep];
    mkdir(settings.workingDir);
    settings.userDir = cd(settings.workingDir);
    % Create SENTINEL file
    fid = fopen(File.SENTINEL, 'wt');
    fwrite(fid, 'SENTINEL');
    fclose(fid);

    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            token = refresh2access(app.driveToken);
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
    recs = Student.resources;
    recs.Problems = solutions;
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
    for s = 1:numel(students)
        student = students(s);
        progress.Message = sprintf('Assessing Student %s', student.name);
        try
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
    
    wait(parfevalOnAll(@getScores, 0, students));
    if app.AnalyzeForCheating.Value
        progress.Message = 'Analyzing Students for Cheating';
        progress.Indeterminate = 'off';
        progress.Value = 0;
        progress.Cancelable = 'on';
        % for each student, we need to compare to all other students.
        scores = cell(1, numel(students));
        for s1 = numel(students):-1:1
            workers(s1) = parfeval(@getScores, 1, students(s1));
        end
        num = numel(workers);
        stop = false;
        while ~all([workers.Read])
            [idx, score] = workers.fetchNext();
            progress.Value = min([progress.Value + 1/num, 1]);
            scores{idx} = score;
            if progress.CancelRequested
                stop = true;
                break;
            end
        end
        if ~stop
            % generate Report
            progress.Message = 'Generating Report';
            progress.Indeterminate = 'on';
            progress.Cancelable = 'off';
            CheatDetector(students, solutions, scores);
        end
    end
    % If the user requested uploading, do it

    if app.UploadToCanvas.Value
        uploadToCanvas(students, app.canvasCourseId, ...
            app.canvasHomeworkId, app.canvasToken, progress);
    end
    if app.UploadToServer.Value
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
        copyfile(pwd, app.localOutputPath);
    end
    if ~isempty(app.localDebugPath)
        % save MAT file
        progress.Indeterminate = 'on';
        progress.Message = 'Saving Debugger Information';
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
    delete(File.SENTINEL);
    % Restore user's path
    path(settings.userPath{1}, '');
    if ~isempty(settings.userPath{2})
        userpath(settings.userPath{2});
    end

    % cd to user's dir
    cd(settings.userDir);

    % Delete our working directory
    [~] = rmdir(settings.workingDir, 's');
    % store debugging info
    app = settings.app;
    if isvalid(settings.progress)
        settings.progress.Message = 'Saving Output for Debugger...';
    end
    if ~isempty(app.localDebugPath)
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
end

function setupRecs(solutions)
    recs = Student.resources;
    recs.Problems = solutions;
end

function scores = getScores(stud)
    persistent students;
    if isempty(students)
        students = stud;
        return;
    end
    scores = cell(1, numel(students));
    for s2 = 1:numel(scores)
        scores{s2} = students(s2).codeSimilarity(stud);
    end
end