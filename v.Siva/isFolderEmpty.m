%% isFolderEmpty Returns true or false for whether or not the given directory is empty
%
%   isEmpty = isFolderEmpty(folderPath)
%
%   Input:
%       folderPath (char)
%           - path to the folder to check if it is empty
%
%   Output:
%       isEmpty (logical)
%           - a logical expressing whether or not the 'folderPath' is empty
%
%   Description:
%       Checks if the given folder path is empty
function isEmpty = isFolderEmpty(folderPath)
    directoryContents = getDirectoryContents(folderPath, true, true);
    isEmpty = length(directoryContents) <= 0;
end