%% autograder: Main responsibility for running the autograder
%
% autograder is called by the Autograder class - it is responsible for running the
% actual steps needed to grade students automatically.
%
%%% Remarks
%
% Main is the entry point for the Autograder. Main will handle any
% exceptions, and will always clean up after itself - the user's folder
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

    % add to path
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
    % Make sure figure's don't show
    settings.figures = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');

    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));

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
            alert(app, 'Exception %s found when trying to download from Canvas', e.identifier);
            app.exception = e;
            return;
        end
    else
        progress.Message = 'Unzipping Student Archive';
        progress.Indeterminate = 'on';
        % unzip the archive
        unzipArchive(app.submissionArchivePath, [pwd filesep 'Students']);
    end

    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            token = refresh2access(app.driveToken);
            downloadFromDrive(app.driveFolderId, token, [pwd filesep 'Solutions'], app.driveKey, progress);
        catch e
            alert(app, 'Exception %s found when trying to download from Google Drive', e.identifier);
            app.exception = e;
            return;
        end
    else
        % unzip the archive
        progress.Indeterminate = 'on';
        progress.Message = 'Unzipping Rubric';
        unzipArchive(app.solutionArchivePath, [pwd filesep 'Solutions']);
    end

    % Generate solutions
    try
        orig = cd('Solutions');
        solutions = generateSolutions(app.isResubmission, progress);
        cd(orig);
        app.solutions = solutions;
    catch e
        % Display to user that we failed
        cd(orig);
        alert(app, 'Problem generation failed. Error %s: %s', e.identifier, ...
            e.message);
        app.exception = e;
        return;
    end

    % Generate students
    try
        students = generateStudents([pwd filesep 'Students'], progress);
        app.students = students;
    catch e
        alert(app, 'Student generation failed. Error %s: %s', e.identifier, ...
            e.message);
        app.exception = e;
        return;
    end

    % Grade students
    recs = Student.resources;
    recs.Problems = solutions;
    plotter = uifigure('Name', 'Grade Report');
    ax = uiaxes(plotter);
    ax.Position = [10 10 550 400]; % as suggested in example on MATLAB ref page
    title(ax, 'Histogram of Student Grades');
    xlabel(ax, 'Grade (in %)');
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
    tic;
    for s = 1:numel(students)
        student = students(s);
        student.assess();
        student.generateFeedback();
        progress.Value = min([progress.Value + 1/numel(students), 1]);
        h.Data(s) = student.grade;
        drawnow;
    end
    t = toc;
    disp(t);

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
        copyfile(pwd, app.localOutputPath);
    end
    close(progress);

end

function alert(app, msg, varargin)
    if nargin == 2
        uialert(app.UIFigure, msg, 'Autograder');
    else
        uialert(app.UIFigure, sprintf(msg, varargin{:}), 'Autograder');
    end
end

function cleanup(settings)
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
    % Restore figure settings
    set(0, 'DefaultFigureVisible', settings.figures);
    % store debugging info
    app = settings.app;
    if ~isempty(app.localDebugPath)
        students = app.students; %#ok<NASGU>
        solutions = app.solutions; %#ok<NASGU>
        exception = app.exception; %#ok<NASGU>
        save([app.localDebugPath filesep 'autograder.mat'], ...
            'students', 'solutions', 'exception');
    end
end