%% NoRecursionSingleFile
% no recursion, but with helper function that does recur, but is NOT
% called.
function [passed, msg] = test
    try
        isRecursive = checkRecur([pwd filesep 'student.m']);
    catch e
        passed = false;
        msg = sprintf('Expected false; got exception %s', e.message);
        return;
    end
    if isRecursive
        passed = false;
        msg = 'Expected false; got true';
    else
        msg = '';
        passed = true;
    end
end