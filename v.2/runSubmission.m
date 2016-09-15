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

    % remove _soln.p files in case students try to cheat by calling the _soln.p files
    p_files = dir('*_soln.p');
    for ndx = 1:length(p_files)
        p_file = p_files(ndx);
        delete(p_file.name);
    end

    % copy files from the supporting files folder to the student folder
    % TODO

    problems = struct([]);
    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);

        problems(ndxProblem).fileExists = exist([problem.name, '.m'], 'file');

        % if the student has a submission for this problem
        if problems(ndxProblem).fileExists
            functionHandle = str2func(problem.name);

            % TODO: implement banned functions
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
                testCases(ndxTestCase).output = runTestCase(functionHandle, testCase, problem.inputs, false, timeout);
            end

            problems(ndxProblem).testCases = testCases;

            rmpath(problem.bannedFunctionsFolderPath);
        end
    end

    student.problems = problems;
    cd(currentDirectory);
end