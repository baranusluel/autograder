%% Valid Student
%
% Given a valid student folder, this will successfully create that student.
function [passed, msg] = test()
    % get solutions
    progress.CancelRequested = false;
    cd('Solutions');
    solutions = generateSolutions(false, progress);
    cd('..');
    % create student
    recs = Student.resources;
    recs.Problems = solutions;
    
    NAME = 'Test User';
    PATH = [pwd filesep 'tuser3'];
    NUM_SUBMISSIONS
    try
        S = Student('Test User', [pwd filesep 'tuser3']);
    catch reason
        passed = false;
        msg = sprintf('Expected Success; got %s - "%s"', reason.identifier, ...
            reason.message);
        return;
    end
    if ~strcmp(NAME, S.name)
        passed = false;
        msg = sprintf('Expected name %s; got %s', NAME, S.name);
        return;
    elseif ~strcmp(PATH, S.path)
        passed = false;
        msg = sprintf('Expected path %s; got "%s"', PATH, S.path);
        return;
    elseif numel(S.submissions) ~= NUM_SUBMISSIONS
        passed = false;
        msg = sprintf('Expected %d subissions; got %d instead', NUM_SUBMISSIONS, numel(S.submissions));
        return;
    elseif ~any(contains(S.submissions, 'helloWorld')) || ~any(contains(S.submissions, 'myFun'))
        passed = false;
        msg = 'Incorrect files found; expected "helloWorld" and "myFun"';
        return;
    else
        passed = true;
        msg = 'Student successfully constructed';
        return;
    end
end