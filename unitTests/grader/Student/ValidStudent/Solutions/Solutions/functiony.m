function[valid]=functiony(header)

%assume that the function header is valid
valid = true;
allInputs = [];
allOutputs = [];
header = strtrim(header);
%check to see whether the function header is longer than the word "function"
if length(header) >= length('function ')
    %check to see whether the header begins with the word function
    if strcmp(header(1:9), 'function ')
        header = header(10:end);
    elseif strcmp(header(1:9),'function[')
        header = header(9:end);
    end
else
    valid = false;
end

%check for valid outputs
if sum(header == '=') == 1
    outputs = strtrim(header(1:strfind(header,'=')-1));
    leftbracket = strfind(outputs,'[');
    rightbracket = strfind(outputs,']');
    header = header(strfind(header,'=')+1:end);
    
    %if there are valid brackets
    if ~isempty(leftbracket) & ~isempty(rightbracket) & rightbracket > leftbracket
        valid = valid && length(outputs)>=2 && outputs(1) == '[' & outputs(end) == ']';
        outputs = strtrim(outputs(leftbracket+1:rightbracket-1));
        
        [out rest] = strtok(outputs, ', ');
        while ~isempty(out)
            valid = valid & isValidVar(strtrim(out));
            allOutputs = [allOutputs {strtrim(out)}];
            [out rest] = strtok(rest, ', ');
        end
        %if there is only one outputs
        valid = valid && (isequal(sort(allOutputs), unique(allOutputs)) || isempty(allOutputs));
    elseif ~isempty(strtrim(outputs))
        valid = valid & isValidVar(strtrim(outputs));
    elseif isempty(strtrim(outputs))
        valid = valid & false;
    end
    
end
%check for valid inputs
leftpara = strfind(header,'(');
rightpara = strfind(header,')');
if ~isempty(leftpara) & ~isempty(rightpara) & rightpara > leftpara
    %check for a valid function names
    [functionName inputs] = strtok(header,'(');
    valid = valid & isValidVar(functionName);
    inputs = strtrim(inputs);
    inputs = inputs(2:end-1);
    [in rest] = strtok(strtrim(inputs), ',');
    while ~isempty(in)
        valid = valid & isValidInput(strtrim(in));
        allInputs = [allInputs {strtrim(in)}];
        [in rest] = strtok(rest, ',');
    end
    valid = valid && (isequal(sort(allInputs), unique(allInputs)) | isempty(allInputs));
else
    %there are no inputs, check for a valid function name
    valid = valid && ~isempty(strtrim(header)) && isValidVar(header);
end
end

%valid variable name checker
function valid = isValidVar(var)
var = lower(strtrim(var));
valid = var(1) >= 'a' & var(1) <= 'z' & all((var >= 'a' & var <= 'z') | (var >= '0' & var <= '9') | var == '_' | var == '-');
valid = valid & ~iskeyword(var);
end

function valid = isValidInput(var)
var = lower(strtrim(var));
if strcmp(var, '~')
    valid = true;
else
    valid = var(1) >= 'a' & var(1) <= 'z' & all((var >= 'a' & var <= 'z') | (var >= '0' & var <= '9') | var == '_' | var == '-');
    valid = valid & ~iskeyword(var);
end
end