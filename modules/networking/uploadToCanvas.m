%% uploadToCanvas: Upload Grades to the Canvas Website
%
% uploadToCanvas will take in an array of Students, as well as the current assignment,
% and will upload their grades.
%
% uploadToCanvas(S, H) will use the student array S and the homework assignment name H to
% automatically upload student grades to Canvas. This uses Canvas's RESTful API, and will
% require a valid OAuth Token.
%
% uploadToCanvas(S, H, O) will do the same as above; however, it will use the options defiend in O.
%
%%% Remarks
%
% uploadToCanvas requires a TA token - preferably an admin token. Tokens can be generated manually
% via the settings page of your Canvas Settings.
%
% Care must be taken with this token. Treat it like your password - anyone who has access to this token
% can do anything, masquerading as you. As such, it is highly recommended you pass in the token instead
% of hardcoding it.
%
% It is assumed that our Canvas page is located at https://gatech.instructure.com
%
% If a grade is manually changed on canvas, the autograder will skip that student, so tweaked grades are retained.
%
% A variety of options can be provided:
%
% * token: A string that represents the authentication token you would like to use.
% * courseId: The ID of the active MATLAB course
% * assignmentId: The ID of the assignment to grade. If given, this overrides homework
%
%%% Exceptions
%
% If the API cannot be reached, an AUTOGRADER:uploadToCanvas:connection exception will be thrown. This
% exception is also thrown if any errors are received as a result of requesting information from (or
% posting information to) the canvas API.
%
% If there is an authentication error, an AUTOGRADER:uploadToCanvas:invalidCredentials exception
% will be thrown.
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
%   T = '...'; % valid token
%   uploadToCanvas(S, H, T);
%
%   Students' grades are uploaded
%
%   S = Student();
%   H = 'Homework 12 - Resubmission';
%   T = ''; % invalid token
%   uploadToCanvas(S, H, T);
%
%   Threw invalidCredentials Exception

function uploadToCanvas(students, homework, varargin)
    if any(isvalid(students))
        return;
    end
    opts = parseOptions(varargin);
    API = 'https://gatech.instructure.com/api/v1/';

    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' opts.token]};
    if isempty(opts.assignmentId)
        % get HW ID:
        data = webread([API 'courses/' opts.courseId '/assignments'], 'search_term', homework, apiOpts);
        % data is structure. If not empty, found hw - get ID
        homework = data.id;
    else
        homework = opts.assignmentId;
    end


    % for each student, get student ID from GT Username. Then, using id, upload grades.
    for s = 1:numel(students)
        % get student id
        apiOpts.RequestMethod = 'GET';
        id = webread([api 'courses/' opts.courseId '.users'], 'search_term', student.id, apiOpts);
        id = id.id;
        % upload student grade
        apiOpts.RequestMethod = 'PUT';
        status = webread([api 'courses/' opts.courseId '/assignments/' homework '/submissions/' id], 'submission[posted_grade]', num2str(s.grade), apiOpts);
    end

end

function outs = parseOptions(ins)
    parser = inputParser();
    parser.addParameter('token', '', @ischar);
    parser.addParameter('courseId', '', @ischar);
    parser.addParameter('assignmentId', '', @ischar);

    parser.parse();
    outs = parser.Results;
end