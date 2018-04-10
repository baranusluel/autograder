%% Valid Student
%
% Given a valid PATH to a student folder containing submissions
% (with filenames FILE1, FILE2, ...):
%
%   NAME = 'Hello';
%   this = Student(PATH, NAME);
%
%   this.name -> "Hello"
%   this.id -> Student's GT username (from name of folder)
%   this.path -> PATH;
%   this.submissions -> ["FILE1", "FILE2", ...];
%   this.feedbacks -> Feedback[];
%   this.isGraded -> false;
function [passed, message] = test()

    name = 'Hello';
    id = 'tuser3';
    p = [pwd filesep id];
    try
        S = Student(p, name);
    catch e
        passed = false;
        message = sprintf('Exception Thrown: %s (%s)', e.identifier, e.message);
        return;
    end
    % check S
    if ~strcmp(S.name, name)
        passed = false;
        message = sprintf('Incorrect name; expected %s, got %s', name, S.name);
        return;
    elseif ~strcmp(S.id, id)
        passed = false;
        message = sprintf('Incorrect ID; expected %s, got %s', id, S.id);
        return;
    elseif ~strcmp(S.path, p)
        passed = false;
        message = sprintf('Path not set correctly; expected "%s", got "%s"', p, S.path);
        return;
    elseif S.isGraded
        passed = false;
        message = 'isGraded set to true, when should be false';
        return;
    elseif ~isempty(S.feedbacks)
        passed = false;
        message = 'feedbacks not empty, when should be empty';
        return;
    end
    % check all files
    files = {'helloWorld.m', 'myFun.m'};
    [passed, message] = studentFileChecker(files, S.submissions);
    if ~passed
        return;
    end
    message = 'Student correctly constructed';
    passed = true;
end