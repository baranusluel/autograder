%% RecursionHelperFunction
% Recursion happens in the helper function, via mutual recursion
function [passed, msg] = test
    try
        isRecursive = checkRecur([pwd filesep 'student.m']);
    catch e
        passed = false;
        msg = sprintf('Expected true; got exception %s', e.message);
        return;
    end
    if ~isRecursive
        passed = false;
        msg = 'Expected true; got false';
    else
        msg = '';
        passed = true;
    end
end