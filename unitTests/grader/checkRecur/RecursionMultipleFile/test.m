%% RecursionMultipleFile
% Recursion happens in the external function, via direct recursion
function [passed, msg] = test
    cd('student');
    try
        isRecursive = checkRecur([pwd filesep 'student.m']);
    catch e
        passed = false;
        msg = sprintf('Expected true; got exception %s', e.message);
        cd('..');
        return;
    end
    cd('..');
    if ~isRecursive
        passed = false;
        msg = 'Expected true; got false';
    else
        msg = '';
        passed = true;
    end
end