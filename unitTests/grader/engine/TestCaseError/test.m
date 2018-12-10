%% Erroring Test Case
%
% Given a test case that errors, throw an error
function [passed, msg] = test()
    p = [pwd filesep 'testcase'];
    info.call = '[out] = helloWorld();';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {};
    T = TestCase(info, p);
    try
        engine(T);
        passed = false;
        msg = 'Expected error; got none';
    catch e
        if strcmp(e.identifier, 'AUTOGRADER:engine:testCaseFailure')
            passed = true;
            msg = '';
        else
            passed = false;
            msg = sprintf('Expected testCaseFailure; got "%s"', e.identifier);
        end
    end
end