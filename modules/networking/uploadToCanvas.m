%% uploadToCanvas: Upload Grades to the Canvas Website
%
% uploadToCanvas will take in an array of Students, as well as the current assignment,
% and will upload their grades.
%
% uploadToCanvas(S, H) will use the student array S and the homework assignment name H to
% automatically upload student grades to Canvas. This uses Canvas's RESTful API, and will
% require a valid OAuth Token.
%
% uploadToCanvas(S, H, T) will do the same as above; however, it will use the token in T (a string)
% for authentication
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