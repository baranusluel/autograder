%% downloadFromCanvas: Download the ZIP archive from Canvas
%
% downloadFromCanvas will download the given assignment to be parsed by the
% autograder
%
% downloadFromCanvas(C, A, T, P) will use the course ID in C, the assignment
% ID in A, the token in T, and the path in P to download and save the homework submission
% in an autograder-ready format in the path specified.
%
%%% Remarks
%
% This is used when instead of pre-downloading a ZIP archive, the user
% wants the autograder to directly download the student's submissions.
%
%%% Exceptions
%
% This will throw a generic AUTOGRADER:networking:connectionError exception
% if something goes wrong with the connection
%
%%% Unit Tests
%
%   % Assume the parameters are correct: C, A, T, P
%   downloadFromCanvas(C, A, T, P);
%
%   In path P, the student folders are all saved, along with a `grades.csv`
%
%   % Assume credentials are incorrect
%   downloadFromCanvas(C, A, T, P);
%
%   threw connectionError exception
