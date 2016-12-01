%% gradeSubmission Grades the given student's function outputs
%
%   student = gradeSubmission(rubric, student)
%
%   Inputs:
%       rubric (struct)
%           - structure representing the rubric and contains details
%           regarding the problems and test cases
%       student (struct)
%           - structure representing a student
%
%   Output(s):
%       student (struct)
%           - the updated structure with the results and grades for the
%           test cases
%
%   Description:
%       Grades a given students' function outputs
function student = gradeSubmission(rubric, student)

    messages = getMessages();

    % initialize student grade
    student.grade = 0;

    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);
        student.problems(ndxProblem).grade = 0;

        if student.problems(ndxProblem).fileExists
            for ndxTestCase = 1:length(problem.testCases)
                testCase = problem.testCases(ndxTestCase);

                % set up score for the test case
                student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput = zeros(1, testCase.numberOfOutputs);

                % if there was not an error when running the student code
                if isempty(student.problems(ndxProblem).testCases(ndxTestCase).output.errors)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Grade Variables
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % checking output variables so isFile flag is false
                    isFile = false;

                    % go through output variables of a test case
                    for ndxVariable = 1:length(testCase.output.variables)

                        if length(student.problems(ndxProblem).testCases(ndxTestCase).output.variables) >= ndxVariable
                            % run compare function to generate if the output is equal and
                            % message corresponding to it
                            [isEqual, message] = compare(student.problems(ndxProblem).testCases(ndxTestCase).output.variables{ndxVariable}, testCase.output.variables{ndxVariable}, isFile);

                            % add points if isEqual
                            if isEqual
                                student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput(ndxVariable) = testCase.pointsPerOutput(ndxVariable);
                            end

                            % add messages
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndxVariable} = message;
                        else
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndxVariable} = messages.variables.incorrectNumberOfOutputs;
                        end

                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Grade Files
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % checking output files next so isFile flag is true
                    isFile = true;

                    % go through output files
                    for ndxFile = 1:length(testCase.output.files)

                        ndx = ndxFile + length(testCase.output.variables);

                        if ~isempty(student.problems(ndxProblem).testCases(ndxTestCase).output.files)
                            filesMask = strcmp(testCase.output.files(ndxFile).name, {student.problems(ndxProblem).testCases(ndxTestCase).output.files(:).name});
                        else
                            filesMask = false;
                        end

                        if any(filesMask)
                            % run compare function to generate if the output is equal and
                            % message corresponding to it
                            [isEqual, message] = compare(student.problems(ndxProblem).testCases(ndxTestCase).output.files(filesMask).value, testCase.output.files(ndxFile).value, isFile);

                            % add points if isEqual
                            if isEqual
                                student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput(ndx) = testCase.pointsPerOutput(ndx);
                            end

                            % add messages
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndx} = message;
                        else
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndx} = messages.files.outputFileNotFound;
                        end
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Grade Plots
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % go through output plots
                    for ndxPlot = 1:length(testCase.output.plots)

                        ndx = ndxPlot + length(testCase.output.variables) + length(testCase.output.files);

                        if length(student.problems(ndxProblem).testCases(ndxTestCase).output.plots) > ndxPlot
                            plotComparisonResult = comparePlots(student.problems(ndxProblem).testCases(ndxTestCase).output.plots(ndxPlot), testCase.output.plots(ndxPlot));

                            plotProperties = fieldnames(plotComparisonResult);
                            for ndxPlotProperty = 1:length(plotProperties)
                                plotProperty = plotProperties{ndxPlotProperty};
                                ndx = ndxPlotProperty + (ndxPlot - 1)*length(plotProperties) + length(testCase.output.variables) + length(testCase.output.files);

                                if plotComparisonResult.(plotProperty)
                                    student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput(ndx) = testCase.pointsPerOutput(ndx);
                                end
                            end
                        else
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndx} = messages.plots.plotNotFound;
                        end

                    end

                end

                student.problems(ndxProblem).testCases(ndxTestCase).grade = sum(student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput);
                student.problems(ndxProblem).grade = student.problems(ndxProblem).grade + sum(student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput);
            end

        end

        student.grade = student.grade + student.problems(ndxProblem).grade;
    end
end