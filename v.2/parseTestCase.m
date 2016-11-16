%% parseTestCase Parses a given test case
%
%   [inputVariables,outputVariables] = parseTestCase(testCase)
%
%   Input:
%       testCase (char)
%           - string representing test case call
%
%   Outputs:
%       inputVariables (cell)
%           - cell array containing the input variables
%       outputVariables (cell)
%           - cell array containing the output variables
%       variableInitialization (char)
%           - part of the string before the function call
%       numberOfOutputs (double)
%           - number of outputs for the function call
%
%   Description:
%       Parses a given test case and returns the inputs and outputs
function [inputVariables, outputVariables, variableInitialization, numberOfOutputs] = parseTestCase(testCase)

    % possible cases
    %   1. myfunc
    %   2. myfunc(...)
    %   3. [] = myfunc
    %   4. [] = myfunc(...)
    %   5. out = myfunc
    %   6. out = myfunc(...)
    %   7. [...] = myfunc
    %   8. [...] = myfunc(...)

    % trim whitespace
    testCase = strtrim(testCase);

    % initialize variables
    hasAssignment  = false;
    hasBrackets    = false;
    assignmentIndex   = length(testCase)+1;
    bracketStartIndex = length(testCase)+1;
    parenthesesStartIndex  = length(testCase);
    semicolonIndex    = 0;

    for i = length(testCase):-1:1

        character = testCase(i);

        if i < bracketStartIndex

            % reached end of function call
            if character == ';' && i < parenthesesStartIndex 

                semicolonIndex = i;
                break

            end

            if character == '='

                hasAssignment = true;
                assignmentIndex = i;

            elseif character == ']'

                hasBrackets = true;
                bracketStartIndex = findMatch(testCase, i);
            
            elseif character == ')'
                parenthesesStartIndex = findMatch(testCase, i);
            end

        end

    end

    % All
    %   3. [] = myfunc
    %   4. [] = myfunc(...)
    %   7. [...] = myfunc
    %   8. [...] = myfunc(...)
    if hasAssignment && hasBrackets
        
        variableInitialization = testCase(1:semicolonIndex);
        [numberOfOutputs, outputVariables] = getNumberOfOutputs(testCase(bracketStartIndex:assignmentIndex-1));
        functionCall = testCase(assignmentIndex+1:end);

    % No brackets
    %   5. out = myfunc
    %   6. out = myfunc(...)
    elseif hasAssignment

        variableInitialization = testCase(1:semicolonIndex);
        numberOfOutputs = 1;
        outputVariables = {testCase(semicolonIndex+1:assignmentIndex-1)};
        functionCall = testCase(assignmentIndex+1:end);

    % No assignment/brackets
    %   1. myfunc
    %   2. myfunc(...)
    else

        variableInitialization = testCase(1:semicolonIndex);
        numberOfOutputs = 0;
        outputVariables = {};
        functionCall = testCase(semicolonIndex+1:end);

    end
    
    inputVariables = getInputVariables(functionCall);

end

function [numberOfOutputs, testCaseOutputs] = getNumberOfOutputs(outputs)

    testCaseOutputs = {};
    numberOfOutputs = 0;
    outputs = strtrim(outputs);
    
    while false == isempty(outputs)
        
        [output,outputs] = strtok(outputs,', []'); %#ok
        
        if ~isempty(output)
            
            testCaseOutputs{end+1} = output; %#ok
            numberOfOutputs = numberOfOutputs + 1;
            
        end
        
    end

end

function startIndex = findMatch(testCase, endIndex)

    characterToMatch = characterMatch(testCase(endIndex));
    startIndex = length(testCase);
    startIndex_ = length(testCase);

    for i = endIndex-1:-1:1

        character = testCase(i);

        if startIndex >= length(testCase)

            if i < startIndex_

                if character == characterToMatch

                    startIndex = i;
                    break;

                elseif any(character == [')' ,'''', ']', '}'])

                    startIndex_ = findMatch(testCase, i);
                    
                end

            end

        end

    end

end

function character = characterMatch(character)

    switch character

        case ')'

            character = '(';

        case ''''
            
            character = '''';

        case '}'
            
            character = '{';

        case ']'
            
            character = '[';

    end

end