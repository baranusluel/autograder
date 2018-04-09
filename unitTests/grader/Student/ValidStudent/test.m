%% ValidStudent
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
function [passed, message] = test();

    name = 'Hello';
    id = 'tuser3';
    p = [pwd filesep id];
    try
        S = Student(p, name);
    catch e
        passed = false;
        message = sprintf('Exception Thrown: %s (%s)', e.identifier, e.description);
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
    if numel(files) ~= numel(S.submissions)
        passed = false;
        message = sprintf('Submission number mismatch; expected %d, got %d', numel(files), numel(S.submissions));
        return;
    end
    for f = 1:numel(files)
        if sum(strcmp(files{f}, S.submissions)) ~= 1
            passed = false;
            message = sprintf('File "%s" was not correctly recorded as a submission', files{f});
            return;
        end
    end
    message = 'Student correctly constructed';
    passed = true;
end