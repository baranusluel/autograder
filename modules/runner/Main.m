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
    % * Create a temporary folder, and copy the student and solution zip
    % files there
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
        

    % Check if given params.
    if isempty(settings.students)
        % uigetfile
        [studName, studPath, ~] = uigetfile('*.zip', 'Select the Student ZIP Archive');
        if isequal(studName, 0) || isequal(studPath, 0)
            return; % (user cancelled)
        else
            settings.students = fullfile(studPath, studName);
        end
    elseif isempty(settings.solutions)
        % throw exception?
        [solnName, solnPath, ~] = uigetfile('*.zip', 'Select the Solutions ZIP Archive');
        if isequal(solnName, 0) || isequal(solnPath, 0)
            return; % (user cancelled)
        else
            settings.solutions = fullfile(solnPath, solnName);
        end
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
    fid = fopen('SENTINEL.lock', 'wt');
    fwrite(fid, 'SENTINEL');
    fclose(fid);
    File.SENTINEL = [pwd filesep 'SENTINEL.lock'];
    
    % Copy zip files
    % rename appropriately (students -> students, solutions -> solutions)
    copyfile(settings.students, [settings.workingDir 'students.zip']);
    copyfile(settings.solutions, [settings.workingDir 'solutions.zip']);
    studPath = [settings.workingDir 'students.zip'];
    solnPath = [settings.workingDir 'solutions.zip'];
    % Remove user's PATH, instate factory default instead:
    settings.userPath = path();
    Student.resetPath();
    
    % Make sure figure's don't show
    settings.figures = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');
    
    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    
    % Generate solutions
    try
        solutions = generateSolutions(solnPath);
    catch e
        % Display to user that we failed
        alert('Problem generation failed. Error %s: %s', e.identifier, ...
            e.message);
        return;
    end
    
    % Generate students
    try
        if strcmpi(inputFormat, 'canvas')
            studPath = canvas2autograder(studPath, settings.workingDir);
        end
        students = generateStudents(studPath);
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
    
    % Formatting
    % format the output
    if strcmpi(outputFormat, 'canvas')
        autograder2canvas(studPath);
    end
    % Uploading
    switch upload
        case {'website'}
            % upload to the website
        case {'canvas'}
            % upload to canvas
        case {'tsquare'}
            % upload to TSquare
    end
    % Save .MAT file
    % Where to save it?
    % Save in pwd for now
    save([settings.userDir filesep 'autograder.mat'], ...
        'students', 'solutions', 'inputFormat', ...
        'outputFormat', 'upload', 'settings');
    
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
    path(settings.userPath, '');
    
    % Copy over any files (?)
    
    % cd to user's dir
    cd(settings.userDir);
    
    % Delete our working directory
    try
        rmdir(settings.workingDir, 's');
    catch
        
    end
    % Restore figure settings
    set(0, 'DefaultFigureVisible', settings.figures);
end

function varargout = parser(args)
    function formatValidator(param)
        formats = {'canvas', 'tsquare', 'autograder'};
        if (isstring(param) && numel(param) ~= 1)
            e = MException('AUTOGRADER:MAIN', ...
                'Input given must be a scalar string or character vector');
            throw(e);
        elseif ~ischar(param) && ~isstring(param)
            e = MException('AUTOGRADER:MAIN', ...
                'Input given must be a scalar string or character vector');
            throw(e);
        elseif ~any(strcmpi(formats, param))
            e = MException('AUTOGRADER:MAIN', ...
                'Unkown input %s; must be one of the following: ''%s''', ...
                param, strjoin(formats, ''', '''));
            throw(e);
        end
    end

    function validator(param)
        if isstring(param) && numel(param) ~= 1
            e = MException('AUTOGRADER:MAIN', ...
                'Input given must be a scalar string or character vector');
            throw(e);
        elseif isstring(param)
            param = char(param);
        end
        if ~ischar(param)
            e = MException('AUTOGRADER:MAIN', ...
                'Input given must be a scalar string or character vector');
            throw(e);
        elseif ~isempty(param)
            formatValidator(param);
        end
    end

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