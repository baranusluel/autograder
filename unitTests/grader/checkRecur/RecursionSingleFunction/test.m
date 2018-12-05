%% RecursionSingleFile
%
% recursion in a single function, single file
function [passed, msg] = test
    try
        isRec = checkRecur([pwd filesep 'student.m']);
    catch e
        msg = sprintf('Expected true; got exception %s', e.message);
        passed = false;
        return;
    end
    if ~isRec
        passed = false;
        msg = 'Expected true; got false';
    else
        passed = true;
        msg = '';
    end
end