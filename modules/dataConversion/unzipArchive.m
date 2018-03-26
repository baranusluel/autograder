%% unzipArchive: Unzips an archive into a specified directory
%   
% unzipArchive unzips an archive into a folder, either creating a temporary
% folder or unzipping into the current folder. Returns the path of the
% unzipped archive.
%
% UNZIPPATH = unzipArchive(PATH) unzips the arhive at PATH into a temp
% directory and returns the path to its contents.
%
% UNZIPPATH = unzipArchive(PATH, DESTINATION) unzips the archive at PATH to
% a folder specified by DESTINATION. If DESTINATION is a folder path, the
% archive will be unzipped to the destination. If DESTINATION is either the
% character vector 'temp', the string "temp", or a logical true, the
% archive will be unzipped to a temporary folder. If DESTINATION is the 
% character vector 'curr', the string "curr", or a logical false, the
% archive will be unzipped to the current directory.
%
% UNZIPPATH = unzipArchive(PATH, DESTINATION, DELETEORIGINAL) has the same
% behavior as the previous usage, however it will delete the archive if
% DELETEORIGINAL is true.
%
%%% Remarks
%
%
%
%%% Exceptions
%
% AUTOGRADER:UNZIPARCHIVE:INVALIDPATH exception will be thrown if an
% invalid path is passed in.
%
% AUTOGRADER:UNZIPARCHIVE:INVALIDFILE exception will be thrown if a non
% archive file is passed in.
%
%%% Unit Tests
%
%   P = unzipArchive('test.zip')
%
%   P contains '\test\' appended to the end of the current directory path 
%   and the contents of test.zip are unzipped into the newly created test\ 
%   folder.
%
%   P = unzipArchive('test.zip', true) or P = unzipArchive('test.zip', 'temp')
%
%   P contains a path to a temporary folder named 'test' somewhere in the
%   temporary appdata designated to MATLAB.
%
%   P = unzipArchive('test.zip', 'curr', true)
%
%   P contains '\test\' appended to the end of the current directory path 
%   and the contents of test.zip are unzipped into the newly created test\ 
%   folder. The original archive test.zip is deleted.
%

function outPath = unzipArchive(originPath, varargin)
    if (nargin == 0)
        unzip(originPath);
    elseif (nargin == 1) 
        unzip(originPath, varagin{1});
    elseif (nargin == 2)
        if islogical(varagin{2}) && ~varargin{2}
            % need to delete the original folder
            
        
    

