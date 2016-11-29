function inputVariables = getInputVariables(functionCall)
    inputVariables = {};
    openingParenthesisIndex = find(functionCall == '(');
    if ~isempty(openingParenthesisIndex)
        closingParenthesisIndex = find(functionCall == ')');
        % get parentheses contents
        inputVariables = functionCall(openingParenthesisIndex+1:closingParenthesisIndex-1);
        % remove spaces
        inputVariables(inputVariables == ' ') = [];
        if ~isempty(inputVariables)
            % get inputs
            inputVariables = strsplit(inputVariables, ',');
        end
    end
end