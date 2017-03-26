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

                    ndx = 0;

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

                    ndx = ndx + length(testCase.output.variables);

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
                    % The student's axis range can be off by this percent of the axis range and still be counted correct
                    AXIS_TOL = .1;
                    DIFFERENCE_FACTOR = 20; % larger number increases tolerance. This is the number of pixels in the downsampled and filtered image that can be different
                    COLOR_TOL = .1; % angle in degrees by which any two histogram vectors may differ and still be considered equal

                    % go through output plots
                    isMoreThanOnePlot = length(testCase.output.plots) > 1;
                    % What is isMoreThanOnePlot? Why do we have it?
                    for ndxPlot = 1:length(testCase.output.plots)

                        ndx = ndx + 1;

                        if length(student.problems(ndxProblem).testCases(ndxTestCase).output.plots) >= ndxPlot
                            studPlot = student.problems(ndxProblem).testCases(ndxTestCase).output.plots(ndxPlot);
                            solnPlot = testCase.output.plots(ndxPlot);

                            isEqual = true(1, 9);
                            outputMessages = cell(1, 9);

                            % check axis labels
                            if ~isequal(studPlot.properties.XLabel, solnPlot.properties.XLabel)
                                isEqual(1) = false;
                                outputMessages{1} = 'The x-axis label differs from the solution';
                            end
                            if ~isequal(studPlot.properties.YLabel, solnPlot.properties.YLabel)
                                isEqual(2) = false;
                                outputMessages{2} = 'The y-axis label differs from the solution';
                            end
                            if ~isequal(studPlot.properties.ZLabel, solnPlot.properties.ZLabel)
                                isEqual(3) = false;
                                outputMessages{3} = 'The z-axis label differs from the solution';
                            end

                            % check the title
                            if ~isequal(studPlot.properties.Title, solnPlot.properties.Title)
                                isEqual(4) = false;
                                outputMessages{4} = 'The title differs from the solution';
                            end

                            % check x axis range
                            range = AXIS_TOL * diff(solnPlot.properties.XLim);
                            if abs(studPlot.properties.XLim(1) - solnPlot.properties.XLim(1)) > range || abs(studPlot.properties.XLim(2) - solnPlot.properties.XLim(2)) > range
                                isEqual(5) = false;
                                outputMessages{5} = 'The x-axis range differs from the solution';
                            end

                            % check y axis range
                            range = AXIS_TOL * diff(solnPlot.properties.YLim);
                            if abs(studPlot.properties.YLim(1) - solnPlot.properties.YLim(1)) > range || abs(studPlot.properties.YLim(2) - solnPlot.properties.YLim(2)) > range
                                isEqual(6) = false;
                                outputMessages{6} = 'The y-axis range differs from the solution';
                            end

                            % check z axis range
                            range = AXIS_TOL * diff(solnPlot.properties.ZLim);
                            if abs(studPlot.properties.ZLim(1) - solnPlot.properties.ZLim(1)) > range || abs(studPlot.properties.ZLim(2) - solnPlot.properties.ZLim(2)) > range
                                isEqual(7) = false;
                                outputMessages{7} = 'The z-axis range differs from the solution';
                            end

                            % check color
                            for ndxLayer = 1:length(solnPlot.histogram)
                                studHist = studPlot.histogram{ndxLayer};
                                solnHist = solnPlot.histogram{ndxLayer};
                                % calculate angle between these two vectors
                                th = acosd(dot(studHist, solnHist) / (norm(studHist) * norm(solnHist)));
                                if th > COLOR_TOL
                                    isEqual(8) = false;
                                    outputMessages{8} = 'The colors differ from the solution';
                                end
                            end

                            % check data visually
                            %%%% THIS IS WHERE HAUSDORFF IMPLEMENTATION
                            %%%% GOES
                            dataDifference = sum(sum(studPlot.imgBWResized ~= solnPlot.imgBWResized));
                            if dataDifference > DIFFERENCE_FACTOR
                                isEqual(9) = false;
                                outputMessages{9} = 'The data values differ from the solution';
                            end

                            % allocate points
                            pointsPerOutput = testCase.pointsPerOutput(ndx:ndx+8);
                            student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput(ndx:ndx+8) = pointsPerOutput.*isEqual;
                            student.problems(ndxProblem).testCases(ndxTestCase).output.messages(ndx:ndx+8) = outputMessages;
                        else
                            student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput(ndx:ndx+8) = zeros(1,9);
                            [student.problems(ndxProblem).testCases(ndxTestCase).output.messages{ndx:ndx+8}] = deal(messages.plots.plotNotFound);
                        end

                        ndx = ndx + 8;

                    end

                end

                student.problems(ndxProblem).testCases(ndxTestCase).grade = sum(student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput);
                student.problems(ndxProblem).grade = student.problems(ndxProblem).grade + sum(student.problems(ndxProblem).testCases(ndxTestCase).pointsPerOutput);
            end

        end

        student.grade = student.grade + student.problems(ndxProblem).grade;
    end
end