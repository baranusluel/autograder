%% InvalidCode
%
function [passed, msg] = test
try
    isRecur = checkRecur([pwd filesep 'student.m']);
catch e
    msg = sprintf('Expected false; got exception %s', e.message);
    passed = false;
    return;
end

if isRecur
    msg = 'Expected false; got true';
    passed = false;
else
    msg = '';
    passed = true;
end
end