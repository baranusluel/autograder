%% uploadToCanvas: Upload Grades to the Canvas Website
%
% uploadToCanvas will take in an array of Students, as well as the current assignment,
% and will upload their grades.
%
% uploadToCanvas(S, C, H, T) will use the student array S, the CourseID C,
% the HomeworkID H, and the Token T to upload student grades to Canvas.
% This uses the LMS RESTful API.
%
%%% Remarks
%
% uploadToCanvas requires a TA token - preferably an admin token. Tokens can be generated manually
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
%   H = 'Homework 12 - Recursion'; % valid HW name
%   uploadToCanvas(S, H);
%
%   Students' grades are uploaded
%
%   S = Student(); % valid student array
%   H = 'Homework 12 - Resubmission'
%   uploadToCanvas(S, H);
%
%   Students' grades are uploaded
%
%   S = Student(); % valid student array
%   H = 'Homework 12 - Recursion'; % valid HW name
%   % NO internet connection
%
%   uploadToCanvas(S, H)
%
%   Threw connection Exception
%
%   S = Student(); % valid student array
%   H = 'Homework 12 - Recursion'; % valid HW name
%   O = struct('token', '...'); % valid token
%   uploadToCanvas(S, H, O);
%
%   Students' grades are uploaded
%
%   S = Student();
%   H = 'Homework 12 - Resubmission';
%   O = struct('token', ''); % invalid token
%   uploadToCanvas(S, H, O);
%
%   Threw connectionError Exception

function uploadToCanvas(students, courseId, assignmentId, token)
    if any(~isvalid(students))
        return;
    end
    API = 'https://gatech.instructure.com/api/v1/';

    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};

    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';

    parfor s = 1:numel(students)
        % get student id
        id = coveredRead([API 'courses/' courseId '/users'], getApiOpts, 'search_term', students(s).id);
        id = id.id;
        data = coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], getApiOpts, 'include[]', 'submission_comments');
        % check if student was hand graded - if we find a comment that says "REGRADE", don't overwrite
        comments = data.submission_comments;
        isRegrade = false;
        for c = 1:numel(comments)
            if strcmp(comments(c).comment, 'REGRADE')
                isRegrade = true;
                break;
            end
        end
        if ~isRegrade
        % upload student grade
            coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], putApiOpts, 'submission[posted_grade]', num2str(s.grade));
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