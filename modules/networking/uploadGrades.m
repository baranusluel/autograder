%% uploadGrades: Upload Grades to the Canvas Website
%
% uploadGrades will take in an array of Students, as well as the current assignment,
% and will upload their grades.
%
% uploadGrades(S, C, H, T, B) will use the student array S, the CourseID C,
% the HomeworkID H, and the Token T to upload student grades to Canvas.
% This uses the LMS RESTful API. Additionally, it updates the progress bar
% B.
%
%%% Remarks
%
% uploadGrades requires a TA token - preferably an admin token. Tokens can be generated manually
% via the settings page of your Canvas Settings.
%
% Care must be taken with this token. Treat it like your password - anyone who has access to this token
% can do anything, masquerading as you.
%
% It is assumed that our Canvas page is located at https://gatech.instructure.com
%
% If a grade is manually changed on canvas, the autograder will skip that student, so tweaked grades are retained.
%
%%% Exceptions
%
% Like other networking functions, this will throw an
% AUTOGRADER:networking:connectionError exception if something goes awry.
%
%%% Unit Tests
%
%   S = Student(); % valid student array
%   C = '12345'; % valid courseID
%   H = '54321'; % valid AssignmentID
%   T = '2096~...'; % valid token
%   B = uiprogressdlg;
%   uploadGrades(S, C, H, T, B)
%
%   Students' grades are uploaded

function uploadGrades(students, courseId, assignmentId, token, progress)
    if any(~isvalid(students))
        return;
    end
    progress.Message = 'Uploading Student Grades to Canvas';
    progress.Indeterminate = 'off';
    progress.Value = 0;
    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};

    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';
    for s = numel(students):-1:1
        stud.name = students(s).name;
        stud.grade = students(s).grade;
        stud.path = students(s).path;
        workers{s} = parfeval(@uploadGrade, 0, ...
            courseId, assignmentId, stud, token);
    end
    workers = [workers{:}];
    
    workers([workers.ID] == -1) = [];
    while ~all([workers.Read])
        fetchNext(workers);
        if progress.CancelRequested
            cancel(workers);
            throw(MException('AUTOGRADER:userCancellation', 'User Cancelled Operation'));
        end
        progress.Value = min([progress.Value + 1/numel(workers), 1]);
    end
end

function uploadGrade(courseId, assignmentId, student, token)
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
    API = 'https://gatech.instructure.com/api/v1/';
    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';
    id = coveredRead([API 'courses/' courseId '/users'], getApiOpts, 'search_term', student.name);
    if ~isempty(id)
        id = num2str(id.id);
        data = coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], getApiOpts, 'include[]', 'submission_comments');
        % check if student was hand graded - if we find a comment that says "REGRADE", don't overwrite
        if ~isempty(data.submission_comments)
            if ~iscell(data.submission_comments)
                comments = {data.submission_comments.comment};
            else
                comments = cellfun(@(s)(s.comment), data.submission_comments, 'uni', false);
            end
        else
            comments = {''};
        end
        if ~any(contains(comments, 'REGRADE', 'IgnoreCase', true))
            coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], putApiOpts, 'submission[posted_grade]', num2str(student.grade));
        end
    end
end

function out = coveredRead(url, opts, varargin)
    try
        out = webread(url, varargin{:}, opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was terminated');
        e = e.addCause(reason);
        throw(e);
    end
end