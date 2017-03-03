%% Split a function call into the function name, the inputs and the outputs
% funcName will be a non-empty string
% inputs will be a 1xN cell array where each entry in the cell array will
% evaluate to the N-th input in the function call, using the eval() function.
% outputs will be a 1xM cell array where each entry is the name of the
% variable where the M-th output would be assigned.
% The function makes no output guarantees when the given function call is not proper
% MATLAB syntax.
function [funcName, inputs, outputs] = getFuncCallParts(call)
% error checking
if ~exist('call') || isempty(call)
    funcName = '';
    inputs = {};
    outputs = {};
    return;
end
% remove trailing semicolons
idx = regexp(call, ';+$');
if ~isempty(idx)
    call(idx:end) = [];
end
funcName = getFuncName(call);
assignIdx = strfind(call, '=');
if ~isempty(assignIdx)
    assignIdx = assignIdx(1);
end
openParenIdx = strfind(call, '(');
if ~isempty(openParenIdx)
    openParenIdx = openParenIdx(1);
end
if ~isempty(assignIdx) && ~isempty(openParenIdx) && assignIdx < openParenIdx % if the call has inputs and outputs
    parts = {call(1:(assignIdx - 1)), call((openParenIdx):end)};
else
    parts = strsplit(call, funcName);
end
if length(parts) > 2
    ins = strjoin(parts(2:end), funcName);
    parts(2:end) = [];
    parts = [parts, ins];
end
outputs = regexp(parts{1}, '\w+', 'match');
inputs = parseInputs(strtrim(parts{2}));
end

%% Parse the inputs part of a function call
% Returns a cell array of all of the inputs such that eval(inCell{i}) will
% return the value of the i-th input to the function
function inCell = parseInputs(str)
inCell = {};
if isempty(strtrim(str))
    return;
end
if str(1) == '('
    str = str(2:end-1);
end
str(end + 1) = ',';
bracketCnt = 0;
inStr = false;
var = '';
for ch = str
    switch ch
        case ''''
            inStr = ~inStr;
        case {'(', '[', '{'}
            bracketCnt = bracketCnt + 1;
        case {')', ']', '}'}
            bracketCnt = bracketCnt - 1;
    end
    if ~inStr && bracketCnt == 0 && (ch == ',' || ch == ' ') && ~isempty(var)
        inCell = [inCell, strtrim(var)];
        var = '';
    else
        var = [var, ch];
    end
end
inCell = [inCell, strtrim(var)];
end

%% Extract the function name from a string of a call to that functions
% Works for functions with any number of inputs or outputs
function name = getFuncName(call)
call = strtrim(call);
fst = find(call=='(', 1);
lst = find(call==')');
if ~isempty(lst)
    lst = lst(end);
end
call(fst:lst) = [];
eq_idx = find(call=='=', 1);
call(1:eq_idx) = [];
name = strtrim(call);
name(name==';') = [];
end