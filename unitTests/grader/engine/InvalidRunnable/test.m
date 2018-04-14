%% Invalid Feedback
%
% Assume F is an invalid Feedback;
% F;
% engine(F);
%
% Threw exception invalidRunnable
function [passed, msg] = test()
    F = Feedback();
    try
        F = engine(F);
        passed = false;
        msg = 'Engine failed to throw exception';
    catch e
        if strcmp(e.identifier, 'AUTOGRADER:engine:invalidRunnable')
            passed = true;
            msg = 'Engine threw correct exception';
        else
            passed = false;
            msg = sprintf('Expected exception invalidRunnable; got %s', e.identifier);
        end
    end
end