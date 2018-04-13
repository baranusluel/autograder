%% No Submissions
%
% If the student had no submissions, the feedback should just have an error
% (exception) that states it wasn't submitted

function [passed, msg] = test()
    info.name = 'helloWorld';
    info.banned = {};
    tInfo.call = 'helloWorld()';
    tInfo.initializer = '';
    tInfo.points = 3;
    tInfo.banned = {};
    tInfo.supportingFiles = {};
    
    T = TestCase(tInfo, [pwd filesep 'soln']);
    info.testCases = {};
    P = Problem(info);
    P.testCases = T;
    
    % valid problem, but no submission
    
    S = Student([pwd filesep 'tuser3'], 'Test User');
    S.gradeProblem(P);
    
    % there should be ONE feedback, and that feedback should have an
    % exception
    if length(S.feedbacks) ~= 1
        passed = false;
        msg = sprintf('Expected 1 problem; got %d', length(S.feedbacks));
        return;
    elseif length(S.feedbacks{1}) ~= 1
        passed = false;
        msg = sprintf('Expected 1 feedback; got %d', length(S.feedbacks{1}));
        return;
    elseif isempty(S.feedbacks{1}.exception)
        passed = false;
        msg = 'Expected exception for Feedback, but got none';
        return;
    elseif ~strcmp(S.feedbacks{1}.exception.identifier, 'AUTOGRADER:Student:fileNotSubmitted')
        passed = false;
        msg = sprintf('Expected fileNotSubmitted exception, got %s', S.feedbacks{1}.exception.identifier);
        return;
    elseif S.feedbacks{1}.points ~= 0
        passed = false;
        msg = sprintf('Expected 0 points; got %d', S.feedbacks{1}.points);
        return;
    else
        passed = true;
        msg = 'No Submission case correctly tested';
    end
end