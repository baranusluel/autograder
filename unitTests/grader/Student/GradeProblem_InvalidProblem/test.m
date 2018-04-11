%% Invalid Problem
%
% An AUTOGRADER:Student:gradeProblem:invalidProblem exception will
% be thrown if PROBLEM is invalid (i.e. if it is empty or
% if name or testcases fields of PROBLEM are empty).
function [passed, message] test()
    try
        S = Student(pwd, 'test');
        % not really a valid student, but doesn't matter since not testing that
        S.gradeProblem(Problem()); % invalid problem
        passed = false;
        message = 'Failed to throw exception when given invalid Problem';
    catch e
        if strcmp(e.identifier, 'AUTOGRADER:Student:gradeProblem:invalidProblem')
            passed = true;
            message = 'Correctly threw exception';
        else
            passed = false;
            message = sprintf('Threw wrong exception. Expected gradeProblem:invalidProblem; got %s', e.identifier);
        end
    end
end