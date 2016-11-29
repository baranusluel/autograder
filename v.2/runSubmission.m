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
%       timeout log handle (double)
%           - text file handle for printing to timeout log
%
%   Output:
%       student (struct)
%           - the updated structure with the output variables for the
%           test cases
%
%   Description:
%       Runs a student's submission
function student = runSubmission(rubric, student, timeoutLogH)
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

    student.timeout.isTimeout = false;
    problems = struct([]);
    % I think you could do this:
    cellProbs = {rubric.problems};
    vecS = cellfun(@(st)(numel(st.testCases)), cellProbs, 'uni', true);
    studentTimeoutMatrix = false(length(rubric.problems), max(vecS));
    % That way, the studentTimeoutMatrix is pre-allocated - this should
    % speed up the autograder!
    % studentTimeoutMatrix = [];
    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);

        problems(ndxProblem).fileExists = exist([problem.name, '.m'], 'file');

        % if the student has a submission for this problem
        if problems(ndxProblem).fileExists
            functionHandle = str2func(problem.name);

            % implement banned functions
            addpath(problem.bannedFunctionsFolderPath);

            % copy files from the supporting files folder to the student folder for the current problem
            copyFilesFromSupportingFilesFolder(rubric.addpath.supportingFiles, problem.supportingFiles, student.folderPaths.submissionAttachments);

            % run each test case
            testCases = struct([]);
            timeoutTestCaseInds = zeros(1, length(problem.testCases));
            for ndxTestCase = 1:length(problem.testCases)
                testCase = problem.testCases(ndxTestCase);
                % set timeout
                if testCase.output.timeElapsed > settings.TIMEOUT_LENIENCY
                    timeout = testCase.output.timeElapsed .* 10;
                else
                    timeout = settings.TIMEOUT_LENIENCY;
                end

                testCases(ndxTestCase).output = runTestCase(functionHandle, testCase, problem.inputs, false, timeout, rubric.addpath.overridenFunctionsFolderPath);
                %if test case timed out
                if ~isempty(testCases(ndxTestCase).output.errors) && (strcmpi(testCases(ndxTestCase).output.errors.message, 'INFINITE LOOP'))
%                    timeoutTestCaseInds = [timeoutTestCaseInds ndxTestCase];
                    timeoutTestCaseInds(ndxTestCase) = ndxTestCase;
                end
%                 % handle timeout
%                 if testCases(ndxTestCase).output.isTimeout
%                     if ~any(strcmp(fieldnames(student), 'problems'))
%                         student.timeout.problems = struct([]);
%                         student.timeout.problems(length(rubric.problems)).testCaseIndices = [];
%                     end
%                     student.timeout.isTimeout = true;
%                     student.timeout.problems(ndxProblem).testCaseIndices(end+1) = ndxTestCase;
%                 end
            end
            
            % the isempty call is unnecessary; if timeoutTestCaseInds is
            % empty, the for loop won't run!
%            if ~isempty(timeoutTestCaseInds)
               %rows are problem #, cols are test case #
               timeoutTestCaseInds = timeoutTestCaseInds(timeoutTestCaseInds ~= 0);
               for testCaseInd = timeoutTestCaseInds
                   studentTimeoutMatrix(ndxProblem, testCaseInd) = true;
               end
%            end
                
            problems(ndxProblem).testCases = testCases;

            rmpath(problem.bannedFunctionsFolderPath);
        end
    end
    
    %log timed out test cases into file -> timeoutLogH
    if any(studentTimeoutMatrix)
        r = size(studentTimeoutMatrix, 1);
        fprintf(timeoutLogH, ['\n' student.displayID '\n']);
        for i = 1:r
            [timedOutTestCases] = find(studentTimeoutMatrix(i,:));
            if ~isempty(timedOutTestCases)
                fprintf(timeoutLogH, '\t%s test cases: %s', rubric.problems(ndxProblem).name, ...
                    strjoin(arrayfun(@num2str, timedOutTestCases, 'uni', false), ', '));
                % This is widely inefficient!
%                timedOutTestCases(1) = [];
%                 for caseInd = timedOutTestCases
%                     fprintf(timeoutLogH, ' ,%d', caseInd);
%                 end
                fprintf(timeoutLogH,'\n');
            end
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