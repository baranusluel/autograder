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
function Main(students, solutions)
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
    
    % Check if given params.
    if ~exist('students', 'var')
        % uigetfile
        [studName, studPath, ~] = uigetfile('*.zip', 'Select the Student ZIP Archive');
        if isequal(studName, 0) || isequal(studPath, 0)
            return; % (user cancelled)
        else
            students = fullfile(studPath, studName);
        end
        [solnName, solnPath, ~] = uigetfile('*.zip', 'Select the Solutions ZIP Archive');
        if isequal(solnName, 0) || isequal(solnPath, 0)
            return; % (user cancelled)
        else
            solutions = fullfile(solnPath, solnName);
        end
    elseif ~exist('solutions', 'var')
        % throw exception?
        throw(MException('AUTOGRADER:INVALIDPATH', ...
            'Expected solution path since given student path; got nothing'));
    elseif ~isfolder(students) || ~isfolder(solutions)
        throw(MException('AUTOGRADER:INVALIDPATH', ...
            'Invalid Path given for students and/or solutions'));
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
    % File.SENTINEL = [pwd filesep 'SENTINEL.lock'];
    
    % Copy zip files
    % rename appropriately (students -> students, solutions -> solutions)
    copyfile(students, [workingDir 'students.zip']);
    copyfile(solutions, [workingDir 'solutions.zip']);
    studPath = [workingDir 'students.zip'];
    solnPath = [workingDir 'solutions.zip'];
    % Remove user's PATH, instate factory default instead:
    settings.userPath = path();
    restoredefaultpath();
    userpath('reset');
    userpath('clear');
    
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
    rmdir(settings.workingDir, 's');
    
    % Restore figure settings
    set(0, 'DefaultFigureVisible', settings.figures);
end