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
% This function is used to find the courseID for Canvas - this is used by virtually all other canvas functions
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
%   T = '..'; % valid token
%   C = getCanvasCourse(T);
%
%   C -> 123456 % numeric courseId
%
%   T = '..'; % valid token
%   N = 'CS 1371 SPR18' % valid exact name
%   C = getCanvasCourse(T, N);
%
%   C -> 123456; % numeric courseId
%
%   T = '...'; % valid token
%   N = 'CS 1371 fdsa'; % INVALID exact name
%   C = getCanvasCourse(T, N);
%
%   Threw notFound exception
