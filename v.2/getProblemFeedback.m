%% getProblemFeedback Grades the given student's function outputs
%
%   student = getProblemFeedback(problem, student, problemNumber)
%
%   Inputs:
%       problem (struct)
%           - structure representing a homework problem and contains
%           details regarding the test cases
%       student (struct)
%           - structure representing a student
%       problemNumber (double)
%           - the number of the problem
%
%   Output:
%       student (struct)
%           - the updated structure with the results and grades for the
%           test cases
%
%   Description:
%       Gets feedback for a student for a single problem
function student = getProblemFeedback(problem, student, problemNumber)

    settings = getSettings();

    student.feedback = sprintf('%s<p><strong>Problem Score:</strong> %.2f/%.2f</p>', student.feedback, student.problems(problemNumber).grade, problem.points);

    for ndxTestCase = 1:length(problem.testCases)
        testCase = problem.testCases(ndxTestCase);

        % concatenate test case number
        student.feedback = sprintf('%s<h3>Test Case %d</h3>', student.feedback, ndxTestCase);

        % concatenate test case
        student.feedback = sprintf('%s<pre>load(''%s'');<br/>%s<br/></pre>', student.feedback, problem.matFile, testCase.call);

        % only run if there is a feedback submission
        if ~student.problems(problemNumber).fileExists
            student.feedback = sprintf('%s<p>ERROR: File does not exist %s</p>', student.feedback, settings.images.RED_CROSS);
        else
            % if there is an error
            if ~isempty(student.problems(problemNumber).testCases(ndxTestCase).output.errors)
                ME = student.problems(problemNumber).testCases(ndxTestCase).output.errors;
                student.feedback = sprintf('%s<p>ERROR: %s %s</p>', student.feedback, getProblemErrorMessage(ME, problem.name), settings.images.RED_CROSS);
            else
                for ndxVariable = 1:length(testCase.outputVariables)

                    pointsReceived = student.problems(problemNumber).testCases(ndxTestCase).pointsPerOutput(ndxVariable);
                    pointsOutOf = testCase.pointsPerOutput(ndxVariable);

                    message = student.problems(problemNumber).testCases(ndxTestCase).output.messages{ndxVariable};
                    outputVariable = testCase.outputVariables{ndxVariable};

                    if pointsReceived == pointsOutOf
                        % concatenate variable
                        student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: PASS (%.2f points) %s</p><br/>', student.feedback, outputVariable, pointsReceived, settings.images.GRN_CHECK);
                    else
                        % concatenate variable
                        student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: FAIL - %s %s</p><br/>', student.feedback, outputVariable, message, settings.images.RED_CROSS);

                        % open table
                        student.feedback = sprintf('%s<table style="padding-left:20px;table-layout:fixed;width:100%%">', student.feedback);

                        % concatenate function value
                        student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>Function Value</p></td><td style="padding-left:10px;word-wrap:break-word">%s</td></tr>', student.feedback, visualizeValue(student.problems(problemNumber).testCases(ndxTestCase).output.variables{ndxVariable}));

                        % concatenate solution value
                        student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>Solution Value</p></td><td style="padding-left:10px;word-wrap:break-word">%s</td></tr>', student.feedback, visualizeValue(testCase.output.variables{ndxVariable}));

                        % close table
                        student.feedback = sprintf('%s</table>', student.feedback);
                    end
                end

                % if there are output files
                if ~isempty(testCase.output.files)

                    studentFiles = student.problems(problemNumber).testCases(ndxTestCase).output.files;
                    studentMessages = student.problems(problemNumber).testCases(ndxTestCase).output.messages;

                    for ndxFile = 1:length(testCase.output.files)
                        file = testCase.output.files(ndxFile);

                        ndx = ndxFile + length(testCase.outputVariables);

                        pointsReceived = student.problems(problemNumber).testCases(ndxTestCase).pointsPerOutput(ndx);
                        pointsOutOf = testCase.pointsPerOutput(ndx);

                        % deal with filename
                        switch file.fileType
                            case {'txt', '.m'}
                                filename = file.name;
                            otherwise
                                % reverse filename and remove .mat
                                [~, filename] = strtok(file.name(end:-1:1), '.');
                                filename(1) = [];

                                % get extension and filename
                                [extension, filename] = strtok(filename, '_');

                                % concatenate filename and extension and reverse
                                filename = [filename(end:-1:2) '.' extension(end:-1:1)];
                        end

                        % if student has output files with the given name
                        if ~isempty(studentFiles) && any(strcmp({studentFiles.name},file.name))

                            message = studentMessages{ndx};

                            if pointsReceived == pointsOutOf
                                student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: PASS (%.2f points) %s</p><br/>', student.feedback, filename, pointsReceived, settings.images.GRN_CHECK);
                            else
                                % get the value of the student and soln files:
                                switch file.fileType
                                    case {'txt', '.m'}
                                        strStudent = studentFiles(strcmp({studentFiles.name},file.name)).value;
                                        strSoln = file.value;
                                        try
                                            % open new files to write (temp files):
                                            fstStudent = tempname;
                                            fstSoln = tempname;
                                            fidStudent = fopen(fstStudent, 'w');
                                            fidSoln = fopen(fstSoln, 'w');
                                            % write the files:
                                            fwrite(fidStudent, strStudent, 'char');
                                            fwrite(fidSoln, strSoln, 'char');
                                            % close the files:
                                            fclose(fidStudent);
                                            fclose(fidSoln);
                                            % get the HTML from visdiff:
                                            strHTML = visdiff(fstSoln, fstStudent);
                                            % delete the temp files:
                                            delete(fstStudent);
                                            delete(fstSoln);
                                            % we'll need to delete/modify some of the
                                            % information in the HTML:
                                                % 1. the full path of the file (just the name should suffice)
                                                % 2. remove all href tags.
                                                % 3. remove the title.
                                                % 4. remove the "toolstrip" msg.
                                                % 5. (possibly) fix the grammar.
                                            % thus, we need to:
                                                % loop through the lines, and do a
                                                % regexp for the href tag.
                                                % loop through the lines, and do a
                                                % regexp for the soln and student file
                                                % names.
                                            % get the lines:
                                            % remove the title:
                                            strHTML = regexprep(strHTML, '<title>{1}?.*?</title>{1}?', '');
                                            % pattern for an href tag:
                                            strPatHref = '\s*?href="javascript.*?;"';
                                            % pattern for a student:
                                            [~, strName, ~] = fileparts(fstStudent);
                                            strPatStud = ['(?<=>{1}?)[^<]*?' strName '{1}?.*?(?=<{1}?)'];
                                            % pattern for the solution:
                                            [~, strName, ~] = fileparts(fstSoln);
                                            strPatSoln = ['(?<=>{1}?)[^<]*?' strName '{1}?.*?(?=<{1}?)'];
                                            % check for href:
                                            strHTML = regexprep(strHTML, strPatHref, '');
                                            % check for the student:
                                            strHTML = regexprep(strHTML, strPatStud, 'Student File');
                                            % check for the solution:
                                            strHTML = regexprep(strHTML, strPatSoln, 'Solution File');
                                            % get the indices for the # differences:
                                            [cellNum, intStart, intEnd] = regexp(strHTML, '(\d*?) differences found\.\s*?Use the toolstrip buttons to navigate to them\.', 'tokens');
                                            intDiff = str2double(cellNum{1}{1});
                                            if intDiff == 1
                                                strHTML = [strHTML(1:(intStart - 1)) '1 difference was found.' strHTML((intEnd + 1):end)];
                                            else
                                                strHTML = [strHTML(1:(intStart - 1)) num2str(intDiff) ' differences were found.' strHTML((intEnd + 1):end)];
                                            end

                                            % concatenate filename
                                            student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: FAIL - %s %s</p><br/>', student.feedback, file.name, message, settings.images.RED_CROSS);

                                            % open table
                                            student.feedback = sprintf('%s<table style="padding-left:20px;table-layout:fixed;width:100%%">', student.feedback);

                                            % add the visdiff output:
                                            student.feedback = sprintf('%s<tr><td style="padding-left:10px;word-wrap:break-word">%s</td><td></td></tr>', student.feedback, strHTML);

                                            % close table
                                            student.feedback = sprintf('%s</table>', student.feedback);
                                        catch
                                            % concatenate filename
                                            student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: FAIL - %s %s</p><br/>', student.feedback, file.name, message, settings.images.RED_CROSS);
                                        end

                                    % presumably _<extension>.mat files
                                    otherwise
                                        % concatenate filename
                                        student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: FAIL - %s %s</p><br/>', student.feedback, filename, message, settings.images.RED_CROSS);

                                        % open table
                                        student.feedback = sprintf('%s<table style="padding-left:20px;table-layout:fixed;width:100%%">', student.feedback);

                                        % concatenate
                                        student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>x-axis</p></td><td style="padding-left:10px;word-wrap:break-word">%s</td></tr>', student.feedback, visualizeValue(studentFiles(strcmp({studentFiles.name},file.name)).value));

                                        % concatenate solution file value
                                        student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>Solution Value</p></td><td style="padding-left:10px;word-wrap:break-word">%s</td></tr>', student.feedback, visualizeValue(file.value));

                                        % close table
                                        student.feedback = sprintf('%s</table>', student.feedback);
                                end
                            end
                        else
                            student.feedback = sprintf('%s<pre style="display:inline">%s</pre><p style="display:inline">: FAIL - FILE DOES NOT EXIST %s</p><br/>', student.feedback, filename, settings.images.RED_CROSS);
                        end
                    end
                end

                % if there are output plots
                if ~isempty(testCase.output.plots)
                    studPlots = student.problems(problemNumber).testCases(ndxTestCase).output.plots;

                    ndx = length(testCase.outputVariables) + length(testCase.output.files);

                    for ndxPlot = 1:length(testCase.output.plots)
                        solnPlot = testCase.output.plots(ndxPlot);

                        ndx = ndx + 1;

                        pointsReceived = student.problems(problemNumber).testCases(ndxTestCase).pointsPerOutput(ndx:ndx+8);
                        pointsOutOf = testCase.pointsPerOutput(ndx:ndx+8);

                        if ~isempty(studPlots) && ndxPlot <= length(studPlots)
                            studPlot = studPlots(ndxPlot);
                            % studMessages = student.problems(problemNumber).testCases(ndxTestCase).output.messages(ndx:ndx+8);

                            if all(pointsReceived == pointsOutOf)
                                student.feedback = sprintf('%s<pre style="display:inline">Plot #%d</pre><p style="display:inline">: PASS (%.2f points) %s</p><br/>', student.feedback, ndxPlot, sum(pointsReceived), settings.images.GRN_CHECK);
                            else
                                student.feedback = sprintf('%s<pre style="display:inline">Plot #%d</pre><p style="display:inline">: FAIL %s</p><br/>', student.feedback, ndxPlot, settings.images.RED_CROSS);

                                % open table
                                student.feedback = sprintf('%s<table style="padding-left:20px;table-layout:fixed;width:100%%">', student.feedback);

                                % check x-axis
                                if pointsReceived(1) == pointsOutOf(1)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>x-label</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(1), pointsOutOf(1), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>x-label</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(1), pointsOutOf(1), settings.images.RED_CROSS);
                                end

                                % check y-axis
                                if pointsReceived(2) == pointsOutOf(2)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>y-label</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(2), pointsOutOf(2), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>y-label</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(2), pointsOutOf(2), settings.images.RED_CROSS);
                                end

                                % check z-axis
                                if pointsReceived(3) == pointsOutOf(3)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>z-label</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(3), pointsOutOf(3), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>z-label</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(3), pointsOutOf(3), settings.images.RED_CROSS);
                                end

                                % check title
                                if pointsReceived(4) == pointsOutOf(4)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>title</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(4), pointsOutOf(4), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>title</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(4), pointsOutOf(4), settings.images.RED_CROSS);
                                end

                                % check x-axis
                                if pointsReceived(5) == pointsOutOf(5)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>x-axis</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(5), pointsOutOf(5), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>x-axis</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(5), pointsOutOf(5), settings.images.RED_CROSS);
                                end

                                % check x-axis
                                if pointsReceived(6) == pointsOutOf(6)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>y-axis</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(6), pointsOutOf(6), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>y-axis</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(6), pointsOutOf(6), settings.images.RED_CROSS);
                                end

                                % check x-axis
                                if pointsReceived(7) == pointsOutOf(7)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>z-axis</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(7), pointsOutOf(7), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>z-axis</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(7), pointsOutOf(7), settings.images.RED_CROSS);
                                end

                                % check x-axis
                                if pointsReceived(8) == pointsOutOf(8)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>color</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(8), pointsOutOf(8), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>color</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(8), pointsOutOf(8), settings.images.RED_CROSS);
                                end

                                % check data
                                if pointsReceived(9) == pointsOutOf(9)
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>data</p></td><td style="padding-left:10px;word-wrap:break-word">PASS (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(9), pointsOutOf(9), settings.images.GRN_CHECK);
                                else
                                    student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>data</p></td><td style="padding-left:10px;word-wrap:break-word">FAIL (%.2f/%.2f) %s</td></tr>', student.feedback, pointsReceived(9), pointsOutOf(9), settings.images.RED_CROSS);
                                end

                                % concatenate function plot image
                                student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>Function Plot</p></td><td style="padding-left:10px;word-wrap:break-word"><img src="data:image/png;base64, %s" /></td></tr>', student.feedback, studPlot.base64img);

                                % concatenate solution plot image
                                student.feedback = sprintf('%s<tr><td style="vertical-align:top;width:50px"><p>Solution Plot</p></td><td style="padding-left:10px;word-wrap:break-word"><img src="data:image/png;base64, %s" /></td></tr>', student.feedback, solnPlot.base64img);

                                % close table
                                student.feedback = sprintf('%s</table>', student.feedback);

                            end
                        else
                            student.feedback = sprintf('%s<pre style="display:inline">Plot #%d</pre><p style="display:inline">: FAIL - PLOT NOT FOUND %s</p><br/>', student.feedback, ndxPlot, settings.images.RED_CROSS);
                        end

                        ndx = ndx + 8;
                    end
                end
            end

            %concatenate test case score
            student.feedback = sprintf('%s<p><em>Test Case Score:</em> %.2f/%.2f</p>', student.feedback, student.problems(problemNumber).testCases(ndxTestCase).grade, testCase.points);
        end
    end
end

function error_message = getProblemErrorMessage(ME, problem_name)
    fields = fieldnames(ME);
    if any(strcmp(fields, 'cause')) && ~isempty(ME.cause)
        ME = ME.cause{1};
        error_message = getProblemErrorMessage(ME, problem_name);
    else
        error_message = sprintf('%s', ME.message);
        if ~isempty(ME.stack)
            line_number = -1;
            for ndx = 1:length(ME.stack)
                if strcmp(ME.stack(ndx).name, problem_name)
                    line_number = ME.stack(ndx).line;
                end
            end
            if line_number > -1
                error_message = sprintf('"%s" in %s at line %d', ME.message, problem_name, line_number);
            end
        end
    end
end