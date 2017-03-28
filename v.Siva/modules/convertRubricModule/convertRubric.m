function convertRubric(fileName)
    [~, ~, extension] = fileparts(fileName);

    disp(sprintf('Reading Rubric File [%s]...', fileName));
    switch extension
        case '.txt'
            [filePath, ~] = fileparts(fileName);

            [hw_num, file_names, prob_weights, prob_preConds, file_tests, file_vars, file_vars_types, prob_test_weights] = rubricParser(fileName)

            hw_num = num2str(hw_num);
            if length(hw_num) == 1
                hw_num = ['0' hw_num];
            end

            for ndxProblem = 1:length(file_names)
                file_name = file_names{ndxProblem};
                [~, problem_name] = fileparts(file_name);
                problem_names{ndxProblem} = problem_name; 
            end
            % start file
            file = sprintf('{\n\t"hw%s_rubric": [\n', hw_num);

            % loop through problems
            for ndxProblem = 1:length(problem_names)
                problem_name = problem_names{ndxProblem};

                % start problem
                file = sprintf('%s\t\t{\n\t\t\t"name": "%s",\n', file, problem_name);

                % start test cases
                file = sprintf('%s\t\t\t"testcases": [\n', file);

                % loop through test cases
                testCases = file_tests{ndxProblem};
                for ndxTestCase = 1:length(testCases)
                    testCase = testCases{ndxTestCase};
                    % strip ending newline characters
                    while testCase(end) == sprintf('\n')
                        testCase(end) = [];
                    end

                    % get inputs
                    startParenthesisIndices = find(testCase == '(');
                    inputsStartIndex = startParenthesisIndices(1)+1;

                    endParenthesisIndices = find(testCase == ')');
                    inputsEndIndex = endParenthesisIndices(end)-1;

                    inputs = testCase(inputsStartIndex:inputsEndIndex);
                    matFileName = sprintf('%s.mat', problem_name);

                    if ~isempty(inputs)
                        isOngoing = false;
                        inputType = '';
                        input = '';
                        for ndxChar = 1:length(inputs)
                            c = inputs(ndxChar);
                            if isOngoing
                                if strcmp(inputType, 'number')
                                    if any(c == '0123456789.-')
                                        input(end+1) = c;
                                    end
                                elseif strcmp(inputType, 'string')
                                    if any(c == '''')
                                        
                                    end
                                end
                            else
                                if any('0123456789.-' == c)
                                    inputType = 'number';
                                    isOngoing = true;
                                elseif c == ''''
                                    inputType = 'string';
                                    isOngoing = true;
                                elseif c == '['
                                    inputType = 'array';
                                    isOngoing = true;
                                end
                            end
                        end
                        inputsArray = strsplit(inputs, ',');

                        for ndxInput = 1:length(inputsArray)
                            variableName = sprintf('in%d', ndxInput);
                            index = strfind(inputs, inputsArray{ndxInput});
                            index = index(1);
                            inputs = sprintf('%s%s%s', inputs(1:index-1), variableName, inputs(index + length(inputsArray{ndxInput}):end));
                            eval(sprintf('%s=%s;', variableName, inputsArray{ndxInput}));
                            variableNames{ndxInput} = variableName;
                        end
                        if ~exist(fullfile(filePath, 'SupportingFiles'), 'dir')
                            movefile(fullfile(filePath, 'Copy Files'), fullfile(filePath, 'SupportingFiles'));
                        end
                        save(fullfile(filePath, 'SupportingFiles', matFileName), variableNames{:});
                    end

                    testCase = [testCase(1:startParenthesisIndices), inputs, testCase(endParenthesisIndices:end)];

                    if ndxTestCase < length(testCases)
                        file = sprintf('%s\t\t\t\t"%s",\n', file, testCase);
                    else
                        file = sprintf('%s\t\t\t\t"%s"\n', file, testCase);
                    end
                end


                % end test cases
                file = sprintf('%s\t\t\t],\n', file);

                % add matFile
                file = sprintf('%s\t\t\t"matFile": "%s",\n', file, matFileName);

                % add points
                points = prob_test_weights{ndxProblem};
                if length(points) == 1
                    points = sprintf('[%d]', points);
                else
                    points = mat2str(points);
                    points = strrep(points, ' ', ',');
                end
                file = sprintf('%s\t\t\t"points": %s,\n', file, points);

                % add banned functions
                file = sprintf('%s\t\t\t"bannedFunctions": []\n', file);

                if ndxProblem < length(problem_names)
                    % end problem
                    file = sprintf('%s\t\t},\n', file);
                else
                    file = sprintf('%s\t\t}\n', file);
                end
            end

            % end file
            file = sprintf('%s\t]\n}', file);

            % write .json file
            fh = fopen(fullfile(filePath, 'rubric.json'), 'w');
            fprintf(fh, file);
            fclose(fh);
        case '.json'

    end
end