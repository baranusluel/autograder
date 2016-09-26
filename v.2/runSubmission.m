%% runSubmission Runs a student's submission
%
%   student = runSubmission(rubric, student)
%
%   Inputs:
%       rubric (struct)
%           - structure representing the rubric and contains details
%           regarding the problems and test cases
%       student (struct)
%           - structure representing a student
%
%   Output:
%       student (struct)
%           - the updated structure with the output variables for the
%           test cases
%
%   Description:
%       Runs a student's submission
function student = runSubmission(rubric, student)
    settings = getSettings();

    currentDirectory = pwd;
    cd(student.folderPaths.submissionAttachments);

    % move _soln.p files to temp folder in case students try to cheat by calling the _soln.p files
    temp_folder_path = tempname;
    mkdir(temp_folder_path);
    p_files = getDirectoryContents('*_soln.p', false, true);
    for ndx_p_file = 1:length(p_files)
        p_file = p_files(ndx_p_file);
        movefile(p_file.name, temp_folder_path);
    end

    % copy files from the supporting files folder to the student folder
    % - I don't think we actually need to do this since we added the supporting files folder to the MATLAB path, but leaving this comment here just so we know to confirm or deny this statement the next time a hw is graded

    problems = struct([]);
    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);

        problems(ndxProblem).fileExists = exist([problem.name, '.m'], 'file');

        % if the student has a submission for this problem
        if problems(ndxProblem).fileExists
            functionHandle = str2func(problem.name);

            % implement banned functions
            addpath(problem.bannedFunctionsFolderPath);

            % run each test case
            testCases = struct([]);

            for ndxTestCase = 1:length(problem.testCases)
                testCase = problem.testCases(ndxTestCase);
                if testCase.output.timeElapsed > settings.TIMEOUT_LENIENCY
                    timeout = testCase.output.timeElapsed .* 10;
                else
                    timeout = settings.TIMEOUT_LENIENCY;
                end
                testCases(ndxTestCase).output = runTestCase(functionHandle, testCase, problem.inputs, false, timeout, rubric.addpath.overridenFunctionsFolderPath);
            end

            problems(ndxProblem).testCases = testCases;

            rmpath(problem.bannedFunctionsFolderPath);
        end
    end

    % move _soln.p files from temp folder back to the student folder
    p_files = getDirectoryContents(fullfile(temp_folder_path, '*_soln.p'), false, true);
    for ndx_p_file = 1:length(p_files)
        p_file = p_files(ndx_p_file);
        movefile(fullfile(temp_folder_path, p_file.name), pwd);
    end

    student.problems = problems;
    cd(currentDirectory);
end