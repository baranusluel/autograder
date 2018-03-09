%% unzipArchive: Unzips an archive into a specified directory
%   
% unzipArchive unzips an archive into a folder, either creating a temporary
% folder or unzipping into the current folder. Returns the path of the
% unzipped archive.
%
% UNZIPPATH = unzipArchive(PATH) unzips the arhive at PATH into the current 
% folder.
%
% UNZIPPATH = unzipArchive(PATH, ISTEMP, DELETEORIGINAL) unzips the archive 
% at PATH into a temporary folder if ISTEMP is true and into the current folder
% otherwise. If DELETEORIGINAL is true, the original archive at PATH will be
% deleted.
%
%%% Remarks
%
%
%
%%% Exceptions
%
%
%
%%% Unit Tests
%
%   P = unzipArchive('students.zip')
%
%   P contains the path of the current directory and the contents of students.zip 
%   are unzipped into the current directory.
%
%   P = unzipArchive('test.zip', true)
%
%   P contains '\test\' appended to the end of the current directory path and the
%   contents of test.zip are unzipped into the newly created test\ folder.
%
%   P = unzipArchive('test.zip', true, true)
%
%   P contains '\test\' appended to the end of the current directory path and the
%   contents of test.zip are unzipped into the newly created test\ folder. The
%   original archive test.zip is deleted.
