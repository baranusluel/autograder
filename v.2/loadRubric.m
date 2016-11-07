%% loadRubric Loads the rubric .json file and formats the content into a struct
%
%   rubric = loadRubric(rubricJSONFilePath)
%
%   Input:
%       rubricJSONFilePath (char)
%           - path to the rubric .json file
%
%   Output:
%       rubric (struct)
%           - a struct containing the details for the problems for the
%           current homework (test cases, points, etc.)
%
%   Description:
%       Loads the rubric .json file and formats the content into a struct
function rubric = loadRubric(rubricJSONFilePath)

    rubricFile = loadjson(rubricJSONFilePath);
    problems = [rubricFile{:}];

    % initialize problem struct
    rubric.problems = struct([]);

    for ndxProblem = 1:length(problems)
        problem = problems(ndxProblem);

        rubric.problems(ndxProblem).name            = problem.funcName;
        rubric.problems(ndxProblem).matFile         = problem.matFiles;
        rubric.problems(ndxProblem).bannedFunctions = problem.banned;

        % check if supFiles is class char (i.e. there is only one test case)
        if isfield(problem, 'supFiles') && ischar(problem.supFiles)
            problem.supFiles = {problem.supFiles};
        else 
            problem.supfiles = {};
        end

        rubric.problems(ndxProblem).supportingFiles = problem.supFiles;

        % check if testcases is class char (i.e. there is only one test case)
        if ischar(problem.tests)
            problem.tests = {problem.tests};
        end

        for ndxTestCase = 1:length(problem.tests)
            rubric.problems(ndxProblem).testCases(ndxTestCase).call = problem.tests{ndxTestCase};
            rubric.problems(ndxProblem).testCases(ndxTestCase).points = problem.points(ndxTestCase);
        end
    end

end