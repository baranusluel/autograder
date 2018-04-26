%% Main: Run the autograder
%
% Main runs the autograder completely, cleaning up after itself and
% generally ensuring nothing is changed in the host environment
%
% Main() Will prompt the user for the student ZIP file, the solution ZIP
% file, and will proceed to run the autograder.
%
% Main(S, N) will run the autograder for the given student and solution zip
% archive paths. If the paths are invalid, it will error.
%
% Main(___, O) will run the autograder with the given options in O, which
% is a structure that holds settings for the autograder.
%
% Main(___, P1, V1, ...) will run the autograder with the given name-value
% pairs, detailed in the Remarks section
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
% The options can be one of the following. If in a structure, the field
% name must match the option. All options are case insensitive.
%
%%% Exceptions
%
% An AUTOGRADER:INVALIDPATH exception will be thrown if either input paths
% are invalid.
%
%%% Unit Tests
%
%   S = ''; % invalid path
%   N = ''; % invalid path
%   Main(S, N);
%
%   Threw AUTOGRADER:invalidPath exception
%
function Main(app)
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
    progress = uiprogressdlg(app.UIFigure, 'Title', 'Progress', ...
        'Message', 'Starting Parallel Pool', 'Cancelable', 'on', ...
        'ShowPercentage', true, 'Indeterminate', 'on');
    evalc('gcp');
    progress.Message = 'Warming up';
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
            progress.Message = 'Fetching Submissions';
            progress.Title = 'Canvas Download Progress';
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
        progress.Title = 'Progress';
        % unzip the archive
        unzipArchive(app.submissionArchivePath, [pwd filesep 'Students']);
    end
    
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            progress.Indeterminate = 'on';
            progress.Message = 'Downloading Rubric from Google Drive';
            progress.Title = 'Progress';
            token = refresh2access(app.driveToken);
            downloadFromDrive(app.driveFolderId, token, [pwd filesep 'Solutions']);
        catch e
            alert(app, 'Exception %s found when trying to download from Google Drive', e.identifier);
            app.exception = e;
            return;
        end
    else
        % unzip the archive
        progress.Indeterminate = 'on';
        progress.Message = 'Unzipping Rubric';
        progress.Title = 'Progress';
        unzipArchive(app.solutionArchivePath, [pwd filesep 'Solutions']);
    end
    
    % Generate solutions
    try
        orig = cd('Solutions');
        progress.Indeterminate = 'off';
        progress.Message = 'Generating Autograder Solutions';
        progress.Title = 'Solution Generation';
        progress.Value = 0;
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
        progress.Indeterminate = 'off';
        progress.Message = 'Generating Student Information';
        progress.Title = 'Student Generation';
        progress.Value = 0;
        students = generateStudents([pwd filesep 'Students']);
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
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Title = 'Grading Progress';
    progress.Message = 'Student Grading Progress';
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
    h.Data = zeros(1, numel(students));
    
    plotter.Visible = 'on';
    for s = 1:numel(students)
        student = students(s);
        student.assess();
        student.generateFeedback();
        progress.Value = min([progress.Value + 1/numel(students), 1]);
        h.Data(s) = student.grade;
        drawnow;
    end
    
    % If the user requested uploading, do it
    
    if app.UploadToCanvas.Value
        progress.Value = 'Upload Progress';
        progress.Message = 'Uploading Student Grades to Canvas';
        progress.Indeterminate = 'off';
        progress.Value = 0;
        uploadToCanvas(students, app.canvasCourseId, ...
            app.canvasHomeworkId, app.canvasToken, progress);
    end
    if app.UploadToServer.Value
        
    end
    
    % if they want the output, do it
    if ~isempty(app.localOutputPath)
        progress.Indeterminate = 'on';
        progress.Title = 'Saving';
        progress.Message = 'Saving Output';
        % save canvas info in path
        % copy csv, then change accordingly
        % move student folders to output path
        if ~isfolder(app.localOutputPath)
            mkdir(app.localOutputPath);
            copyfile(pwd, app.localOutputPath);
        end     
    end
    if ~isempty(app.localDebugPath)
        % save MAT file
        progress.Indeterminate = 'on';
        progress.Title = 'Saving';
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