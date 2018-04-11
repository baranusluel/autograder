%% Missing Feedback
%
% An AUTOGRADER:Student:generateFeedback:missingFeedback exception
% will be thrown if the feedbacks field of the Student is empty
% (i.e. if gradeProblem wasn't invoked first).
%
function [passed, message] = test()
    S = Student(pwd, 'test');
    try
        S.generateFeedback();
        passed = false;
        message = 'Student failed to throw exception for invalid state';
    catch e
        if strcmp(e.identifier, 'AUTOGRADER:Student:generateFeedback:missingFeedback')
            passed = true;
            message = 'Student correctly threw exception';
        else
            passed = false;
            message = sprintf('Threw wrong exception. Expected generateFeedback:missingFeedback, got %s', e.identifier);
        end
    end
end