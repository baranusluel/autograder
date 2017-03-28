%% getDirectoryContents Gets the contents of the given folder location
%
%   directoryContents = getDirectoryContents(folderPath, keepFolders, keepFiles)
%
%   Inputs:
%       folderPath (char)
%           - path to the folder to get the contents of
%       keepFolders (logical)
%           - whether or not the folders are to be returned
%       keepFiles (logical)
%           - whether or not the files are to be returned
%
%   Output:
%       directoryContents (struct)
%           - a struct containing files and folders in the given folder
%           location
%
%   Description:
%       Gets the contents of the given folder location and return folders
%       and files as appropriate
function directoryContents = getDirectoryContents(folderPath, keepFolders, keepFiles)
    directoryContents = dir(folderPath);

    % remove hidden folders (starts with '.')
    directoryContents(cellfun(@(x)(x(1) == '.' || x(1) == '$'), {directoryContents.name})) = [];

    folders = [];
    if keepFolders
        folders = directoryContents([directoryContents.isdir]);
    end

    files = [];
    if keepFiles
        files = directoryContents(~[directoryContents.isdir]);
    end

    directoryContents = [folders files];
end