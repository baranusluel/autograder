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
% * inputFormat: The format of the input ZIP student archive. Can be one of
% the following: 'canvas' or 'tsqaure'. Default is 'canvas'
%
% * outputFormat: The format of the output to write. Can be one of the
% following: 'canvas' or 'tsquare'. Default is 'canvas'
%
% * upload: A string. If 'website', then it will only upload to the CS 1371
% website. If 'all', then it will upload to the CS 1371 website & the given
% format - if the outputFormat is 'canvas', it will upload to the canvas
% website, for example. If upload is empty, then no uploads take
% place.
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
%   Threw AUTOGRADER:INVALIDPATH exception
%
function Main(varargin)
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
    [
        settings.students, ...
        settings.solutions, ...
        settings.inputFormat, ...
        settings.outputFormat, ...
        settings.upload ...
    ] = parser(varargin);
        
    % Show the app. After it's done (uiresume), we'll extract necessary
    % info and then change to updating. If it's cancelled, we'll exit
    % gracefully.
    
    % add to path
    settings.userPath = {path(), userpath()};
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    clear Student;
    Student.resetPath();
    
    % start up application
    app = Autograder();
    uiwait(app.UIFigure);
    if ~isvalid(app)
        return;
    end
    % Start up parallel pool
    if isempty(gcp)
        parpool(2);
    end
    
    % Get temporary directory
    settings.workingDir = [tempname filesep];
    mkdir(settings.workingDir);
    settings.userDir = cd(settings.workingDir);
    % Create SENTINEL file
    fid = fopen(File.SENTINEL, 'wt');
    fwrite(fid, 'SENTINEL');
    fclose(fid);
    
    % For submission, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Students');
    if app.HomeworkChoice.Value == 1
        % downloading. We should create new Students folder and download
        % there.
        try
            downloadFromCanvas(app.courseId, app.assignmentId, ...
                app.canvasToken, [pwd filesep 'Students']);
        catch e
            % alert in some way and return
            alert('Exception %s found when trying to download from Canvas', e.identifier);
            return;
        end
    else
        % unzip the archive
        unzipArchive(app.submissionArchivePath, [pwd filesep 'Students']);
    end
    
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            downloadFromDrive(app.driveFolderId, app.driveToken);
        catch e
            alert('Exception %s found when trying to download from Google Drive', e.identifier);
            return;
        end
    else
        % unzip the archive
        unzipArchive(app.solutionArchivePath, [pwd filesep 'Solutions']);
    end
    
    % Make sure figure's don't show
    settings.figures = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');
    
    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    
    % Generate solutions
    try
        solutions = generateSolutions([pwd filesep 'Solutions']);
    catch e
        % Display to user that we failed
        alert('Problem generation failed. Error %s: %s', e.identifier, ...
            e.message);
        return;
    end
    
    % Generate students
    try
        students = generateStudents([pwd filesep 'Students']);
    catch e
        alert('Student generation failed. Error %s: %s', e.identifier, ...
            e.message);
        return;
    end
    
    % Grade students
    %
    % There are a couple of ways to do this. I've listed them below:
    %
    % * For each student, for each problem, grade the problem and provide
    % feedback
    % * For each student, for each problem, grade the problem. For each
    % student, generate the feedback
    % * For each problem for each student, grade the problem. For each
    % student, generate the feedback
    %
    % I am going to choose option one. I think this will have a better
    % performance measure, but that's just a gut decision. If anyone has
    % any better ideas, I'm all ears!
    %
    % Also, if we grade and provide feedback all at once, then if either
    % step will fail, it will fail fast (at the first student) rather than
    % after all grading has been done.
    for s = 1:numel(students)
        student = students(s);
        for p = 1:numel(solutions)
            problem = problems(p);
            student.gradeProblem(problem);
            student.generateFeedback();
        end
    end
    
    % If the user requested uploading, do it
    if app.UploadToCanvas.Value
        opts.token = app.canvasToken;
        if ~isempty(app.canvasCourseId)
            opts.courseId = app.canvasCourseId;
        end
        if ~isempty(app.canvasHomeworkId)
            opts.homeworkId = app.canvasHomeworkId;
        end
        uploadToCanvas(students, [], opts);
    end
    if app.UploadToServer.Value
        
    end
    
    % if they want the output, do it
    if ~isempty(app.localOutputPath)
        % save canvas info in path
        % copy csv, then change accordingly
    end
    if ~isempty(app.localDebugPath)
        % save MAT file
        save([app.localDebugPath filesep 'autograder.mat'], ...
            'students', 'solutions', 'settings', 'app');
    end
    
end

function alert(msg, params)
    if ~exist('params', 'var') || isempty(params)
        fprintf(2, '%s\n', msg);
    else
        fprintf(2, [msg '\n'], params{:});
    end
end

function cleanup(settings)
    % Cleanup
    % Delete the parallel pool
    if ~isempty(gcp('nocreate'))
        delete(gcp);
    end
    
    % Restore user's path
    path(settings.userPath{1}, '');
    userpath(settings.userPath{2});
    
    % cd to user's dir
    cd(settings.userDir);
    
    % Delete our working directory
    [~] = rmdir(settings.workingDir, 's');
    % Restore figure settings
    set(0, 'DefaultFigureVisible', settings.figures);
    % delete SENTINEL
    delete(File.SENTINEL);
end

function varargout = parser(args)

    inputs = inputParser();
    inputs.CaseSensitive = false;
    inputs.FunctionName = 'Autograder';
    inputs.addOptional("students", '', @isfile);
    inputs.addOptional("solutions", '', @isfile);
    inputs.addParameter("inputFormat", 'canvas', @formatValidator);
    inputs.addParameter("outputFormat", 'canvas', @formatValidator);
    inputs.addParameter("upload", '', @validator);
    inputs.parse(args{:});
    varargout{1} = inputs.Results.students;
    varargout{2} = inputs.Results.solutions;
    varargout{3} = inputs.Results.inputFormat;
    varargout{4} = inputs.Results.outputFormat;
    varargout{5} = inputs.Results.upload;
end