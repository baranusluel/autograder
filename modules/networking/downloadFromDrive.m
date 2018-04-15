%% downloadFromDrive: Download the solutions from Google Drive
%
% downloadFromDrive will download the |grader| folder from Google Drive
%
% downloadFromDrive(F, T, P) will use the token in T to download the folder ID
% in F. It will recursively download everything within that folder. The
% files will be saved within the same heirarchy in path P.
%
%%% Remarks
%
% This is used to download solution archives from Google Drive, but it
% could be used to download anything from Google Drive, theoretically. It
% is agnostic about what it's actually downloading
%
%%% Exceptions
%
% Like other |networking| functions, this will throw an
% AUTOGRADER:networking:connectionError exception if a connection is
% interrupted.
%
%%% Unit Tests
%
%   T = '...'; % valid access token
%   F = '...'; % valid FolderID
%   downloadFromDrive(F, T, pwd);
%
%   There is now a grader folder in the current directory
%
%   T = '';
%   F = '';
%   downloadFromDrive(F, T, pwd);
%
%   threw connectionError exception
%