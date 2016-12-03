%% runSolutions Runs through the test cases for each problem with the solutions
%
%   rubric = runSolutions(rubric)
%
%   Input:
%       rubric (struct)
%           - a struct containing the details for the problems for the
%           current homework (test cases, points, etc.)
%
%   Output:
%       rubric (struct)
%           - the updated struct containing the details for the problems
%           for the current homework (test cases, points, solutions, etc.)
%
%   Description:
%       Runs the solutions and stores additional information into the
%       rubric
function rubric = runSolutions(rubric)
    currentDirectory = pwd;
    cd(rubric.folderPaths.solutions);
    problems = struct([]);

    % initialize random number generator so that later when using rng when grading students
    % the stream will be the same (default seed 0)
    RandStream.setGlobalStream(RandStream('twister'));
    setRandStream = @() RandStream.setGlobalStream(RandStream('twister'));
    f = parfeval(setRandStream, 0);
    fetchNext(f);

    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);
        functionHandle = str2func(problem.name);

        % load .mat file
        matFilePath = fullfile(rubric.addpath.supportingFiles, problem.matFile);
        if exist(matFilePath, 'file') && ~isempty(problem.matFile)
            problem.inputs = load(matFilePath);
        else
            problem.inputs = struct();
        end

        % create banned functions
        problem.bannedFunctionsFolderPath = overrideBannedFunctions(fullfile(rubric.folderPaths.rubric, 'bannedFunctions'), problem.bannedFunctions, ndxProblem, problem.name);

        % copy files from the supporting files folder to the solution folder for the current problem
        copyFilesFromSupportingFilesFolder(rubric.addpath.supportingFiles, problem.supportingFiles, rubric.folderPaths.solutions);

        % run each test case
        testCases = struct([]);
        for ndxTestCase = 1:length(problem.testCases)
            testCase = problem.testCases(ndxTestCase);
            [testCase.inputVariables, testCase.outputVariables] = parseTestCase(testCase.call);
            testCase.output = runTestCase(functionHandle, testCase, problem.inputs, true, [], rubric.addpath.overridenFunctionsFolderPath);

            numberOfVariables = length(testCase.output.variables);
            numberOfFiles     = length(testCase.output.files);
            numberOfPlots     = length(testCase.output.plots);

            % 9 -> x-label, y-label, z-label, title, x-limits, y-limits, z-limits, colors, data
            pointsBreakDown = testCase.points ./ (numberOfVariables + numberOfFiles + numberOfPlots);
            testCase.numberOfOutputs = numberOfVariables + numberOfFiles + numberOfPlots * 9;
            testCase.pointsPerOutput = ones(1, testCase.numberOfOutputs);
            ndxPointsPerOutput = 1;
            for ndxPoints = 1:length(pointsBreakDown)
                if ndxPoints <= numberOfVariables
                    testCase.pointsPerOutput(ndxPointsPerOutput) = pointsBreakDown(ndxPoints);
                    ndxPointsPerOutput = ndxPointsPerOutput + 1;
                elseif ndxPoints <= numberOfFiles
                    testCase.pointsPerOutput(ndxPointsPerOutput) = pointsBreakDown(ndxPoints);
                    ndxPointsPerOutput = ndxPointsPerOutput + 1;
                elseif ndxPoints <= numberOfPlots
                    testCase.pointsPerOutput(ndxPointsPerOutput:ndxPointsPerOutput+8) = pointsBreakDown(ndxPoints) .* [[ones(1, 8).*0.02],0.84];
                    ndxPointsPerOutput = ndxPointsPerOutput + 9;
                end
            end
            testCases = [testCases, testCase]; %#ok
        end

        problem.testCases = testCases;
        problem.points = sum([testCases(:).points]);
        problems = [problems, problem]; %#ok
    end

    rubric.problems = problems;
    rubric.points = sum([problems(:).points]);
    cd(currentDirectory);
end