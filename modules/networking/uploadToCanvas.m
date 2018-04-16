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
%   Threw invalidCredentials Exception

function uploadToCanvas(students, homework, varargin)
    if any(~isvalid(students))
        return;
    end
    opts = parseOptions(varargin);
    API = 'https://gatech.instructure.com/api/v1/';
    COURSE_CODE = 'CS 1371';

    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' opts.token]};

    if isempty(opts.courseId)
        % find course ID; it will be the only course active
        data = coveredRead([API 'courses/'], apiOpts);
        % data will PROBABLY be a cell array
        if ~iscell(data)
            % a stucture. num2cell it and proceed
            data = num2cell(data);
        end
        % loop through all data; if we find an end_at that fits, with the course_code starting with 'CS 1371', that's our guy!
        for d = 1:numel(data)
            ending = datetime(data{d}.end_at,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'America/New_York');
            starting = datetime(data{d}.start_at,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'America/New_York');
            ending.TimeZone = '';
            starting.TimeZone = '';
            % if our date is between and name matches, engage. Note that TA course never has a space
            if strncmp(data{d}.course_code, COURSE_CODE, length(COURSE_CODE)) && starting < datetime() && ending > datetime()
                % This is our course!
                opts.courseId = d.id;
                break;
            end
        end
    end

    if isempty(opts.assignmentId)
        % get HW ID:
        data = coveredRead([API 'courses/' num2str(opts.courseId) '/assignments'], apiOpts, 'search_term', homework);
        if isfield(data, 'id') && ~isempty(data.id)
            opts.assignmentId = data.id;
        else
            e = MException('AUTOGRADER:uploadToCanvas:dataNotFound', ...
                'Could not find assignment');
            throw(e);
        end
    end


    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';

    courseId = num2str(opts.courseId);
    assignmentId = num2str(opts.assignmentId);
    studentId = student.id;
    parfor s = 1:numel(students)
        % get student id
        id = coveredRead([API 'courses/' courseId '/users'], getApiOpts, 'search_term', studentId);
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

function outs = parseOptions(ins)
    parser = inputParser();
    parser.addParameter('token', '', @ischar);
    parser.addParameter('courseId', '', @ischar);
    parser.addParameter('assignmentId', '', @ischar);

    parser.parse(ins{:});
    outs = parser.Results;
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