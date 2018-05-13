%% Infinite Loop Testing
%
% If a student loops infinitely, then there should be no exception. The
% test case should not take longer than 30 seconds (ideally), and an
% infiniteLoop exception should be attached to the feedback
function [passed, msg] = test()
    p = [pwd filesep 'testCase'];
    info.call = '[out] = helloWorld(in);';
    info.supportingFiles = {[p filesep 'vars_rubrica.mat']};
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    T = TestCase(info, p);
    F = Feedback(T, [pwd filesep 'tuser3']);
    try
        F2 = engine(F);
        % should be in exception field
        if isempty(F2.exception)
            passed = false;
            msg = 'Expected exception for Student; got nothing';
            return;
        elseif ~strcmp('AUTOGRADER:studentCodeError', F2.exception.identifier)
            passed = false;
            msg = sprintf('Expected "AUTOGRADER:studentCodeError" exception, got "%s"', ...
                F2.exception.identifier);
            return;
        else
            passed = true;
            msg = 'Correctly attached exception';
        end
    catch e
        passed = false;
        msg = sprintf('Expected no exception; got %s', e.identifier);
    end
end