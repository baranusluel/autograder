%% Invalid Student Code
%
% The Student Code is invalid - don't throw the exception, log it
function [passed, msg] = test()
    info.call = '[out] = helloWorld()';
    info.initializer = '';
    info.points = 10;
    info.banned = {};
    info.supportingFiles = {};
    T = TestCase(info, [pwd filesep 'soln']);
    T = engine(T);
    F = Feedback(T, [pwd filesep 'tuser3']);
    try
        F2 = engine(F);
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception "%s"', e.identifier);
        return;
    end
    if isempty(F2.exception)
        passed = false;
        msg = 'Expected exception, but no exception was found';
        return;
    else
        passed = true;
        msg = '';
        return;
    end
end