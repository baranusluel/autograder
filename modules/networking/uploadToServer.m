%% uploadToServer: Upload the student's submission files to the Server
%
% uploadToServer is responsible for uploading files to the CS 1371 Server
%
% uploadToServer(S, H, P, U, W, B) will upload the files for students in 
% array S to the host H, at port P, using the username U and the password
% W. Additionally, it will update the progress bar B.
%
%%% Remarks
%
% This method is used to upload student files to the CS 1371 website, so
% that the students can view them.
%
%%% Exceptions
%
% This method, like all other networking methods, will throw an
% AUTOGRADER:networking:connectionError exception if interrupted.
%
%%% Unit Tests
%
%   S = Student(); % valid student array
%   H = 'cs1371.gatech.edu'; % valid host
%   P = 22; % valid port
%   U = 'autograder'; % valid username
%   W = 'password'; % valid password
%   B = uiprogressdlg;
%   uploadToServer(S, H, P, U, W, B);
%
%   Student files are correctly uploaded
function uploadToServer(students, host, port, username, password, progress)
