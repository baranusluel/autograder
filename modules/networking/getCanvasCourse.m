%% getCanvasCourse: Gets the Canvas CourseID associated with the given course
%
% getCanvasCourse will return a courseID to be used when talking with the Canvas API
%
% C = getCanvasCourse(T) will use the token T to find the most likely candidate for the current course.
% This is based on name and it still being in progress.
%
% C = getCanvasCourse(T, N) will use the name N to search for a course with that name. If no exact matches
% are found, an error is returned
%
%%% Remarks
%
% This function is used to find the courseID for Canvas - this is used by 
% virtually all other canvas functions
%
%%% Exceptions
%
% If a name is given, but a course isn't found, and AUTOGRADER:getCanvasCourse:notFound exception
% is thrown.
%
% As with all the other networking functions, if a connection error occurs, an AUTOGRADER:networking:connectionError
% exception is thrown
%
%%% Unit Tests
%
%   T = '...'; % valid token
%   C = getCanvasCourse(T);
%
%   C -> '123456'
%
%   T = '...'; % valid token
%   N = 'CS 1371 SPR18' % valid exact name
%   C = getCanvasCourse(T, N);
%
%   C -> '123456' % numeric courseId
%
%   T = '...'; % valid token
%   N = 'CS 1371 fdsa'; % INVALID exact name
%   C = getCanvasCourse(T, N);
%
%   Threw notFound exception
function courseId = getCanvasCourse(token, code)
    if nargin < 2
        code = 'CS 1371';
    end
    API = 'https://gatech.instructure.com/api/v1/';

    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};

    % find course ID; it will be the only course active
    try
        data = webread([API 'courses/'], apiOpts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'A connection error occurred');
        e = e.addCause(reason);
        throw(e);
    end
    % data will PROBABLY be a cell array
    if ~iscell(data)
        % a stucture. num2cell it and proceed
        data = num2cell(data);
    end
    % loop through all data; if we find an end_at that fits, with the course_code starting with 'CS 1371', that's our guy!
    isFound = false;
    for d = 1:numel(data)
        ending = datetime(data{d}.end_at,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'America/New_York');
        starting = datetime(data{d}.start_at,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'America/New_York');
        ending.TimeZone = '';
        starting.TimeZone = '';
        % if our date is between and name matches, engage. Note that TA course never has a space
        if strncmp(data{d}.course_code, code, length(code)) && starting < datetime() && ending > datetime()
            % This is our course!
            courseId = num2str(d.id);
            isFound = true;
            break;
        end
    end
    if ~isFound
        e = MException('AUTOGRADER:getCanvasCourse:notFound', 'Course with name %s not found', code);
        throw(e);
    end
end