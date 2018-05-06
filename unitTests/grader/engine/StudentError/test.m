% Student Code errors
%
%   Assume F is a valid Feedback with a valid TestCase
%   F = Feedback(...);
%   engine(F);
%
%   F now has files, outputs, etc. filled in correctly
function [passed, msg] = test()
    p = [pwd filesep 'feedback'];
    info.call = '[out] = helloWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {[p filesep 'vars_rubrica.mat']};
    T = TestCase(info, [pwd filesep 'soln']);
    F = Feedback(T, p);
    try
        F2 = engine(F);
        % F2 should have exception field
        if isempty(F2.exception)
            passed = false;
            msg = 'Student exception not caught correctly';
            return;
        elseif ~strcmp(F2.exception.identifier, 'AUTOGRADER:studentCodeError')
            passed = false;
            msg = sprintf('Expected studentCodeError exception; got %s', ...
                F2.exception.identifier);
            return;
        else
            passed = true;
            msg = 'Attached correct exception';
        end
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s', e.identifier);
    end
end
