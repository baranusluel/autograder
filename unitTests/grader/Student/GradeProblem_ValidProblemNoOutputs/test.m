%% Valid Problem
%
% This will grade a valid problem (outputs only)
function [passed, msg] = test()
    % generate Problem first
    info.name = 'helloWorld';
    info.banned = {};
    info.isRecursive = false;
    info.supportingFiles = {'vars.mat'};
    tInfo.call = '[out1, out2] = helloWorld(in1);';
    tInfo.initializer = '';
    tInfo.points = 4;
    
    info.testCases = tInfo;
    cd('soln');
    P = Problem(info);
    cd('..');
    
    S = Student([pwd filesep 'tuzer3'], 'Turgay Uzer');
    
    try
        S.gradeProblem(P);
    catch e
        passed = false;
        msg = sprintf('Exception %s: %s thrown', e.identifier, e.message);
        return;
    end
    % check feedbacks
    if isempty(S.feedbacks) || isempty(S.feedbacks{1})
        passed = false;
        msg = 'Expected feedback; found none';
        return;
    elseif numel(S.feedbacks{1}) ~= 1
        passed = false;
        msg = sprintf('Expected 1 feedback; got %d', numel(S.feedbacks{1}));
        return;
    end
    
    feed = S.feedbacks{1};
    % check all points were given
    if ~isequal(tInfo.points, feed.points)
        passed = false;
        msg = sprintf('Expected %0.2f points, got %0.2f', tInfo.points, feed.points);
        return;
    end
    
    if isempty(feed.hasPassed)
        passed = false;
        msg = 'Expected true for hasPassed; got empty';
        return;
    elseif ~feed.hasPassed
        passed = false;
        msg = 'Expected true for hasPassed; got false';
        return;
    end
    
    passed = true;
    msg = 'Student graded successfully';
end