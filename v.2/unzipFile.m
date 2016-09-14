%% unzipFile Unzips a file to a given destination
%
%   folderPath = unzipFile(zipFilePath, destinationFolderPath)
%
%   Inputs:
%       zipFilePath (char)
%           - path to the .zip file to unzip
%       destinationFolderPath (char)
%           - path to the location to unzip the .zip file to
%
%   Output:
%       folderPath (char)
%           - path to the resulting unzipped folder
%
%   Description:
%       Unzips the given .zip file to the destination location and returns
%       the resulting folder
function folderPath = unzipFile(zipFilePath, destinationFolderPath)

    % get system temporary directoryContents
    temporaryFilePath = tempname;

    % unzip
    unzip(zipFilePath, temporaryFilePath);

    % get folders
    directoryContents  = getDirectoryContents(temporaryFilePath, true, false);

    % get index of last modified folder (unzipped folder)
    [~, ndx] = max([directoryContents.datenum]);

    % get last modified folder name
    folder = directoryContents(ndx).name;
    % get folder path in destination folder
    folderPath = fullfile(destinationFolderPath, folder);

    % move unzipped folder from the temporary path to the destination folder
    movefile(fullfile(temporaryFilePath,folder), destinationFolderPath);

    % clean up
    rmdir(temporaryFilePath,'s');

end