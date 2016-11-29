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

    % unzip
    if nargin == 1
        destinationFolderPath = pwd;
    end
    if ispc
        % get folders
        oldDirectoryContents  = getDirectoryContents(destinationFolderPath, true, false);
        
        [result, msg] = system(['7z x "' zipFilePath '" -o"' destinationFolderPath '"']);
        if result ~= 0
            error(struct('message', sprintf('7-Zip failed to convert. Here''s the message: %s', msg), ...
                'identifier', 'MATLAB:UnzipFile:SystemCall'));
        end
        % get folders
        newDirectoryContents  = getDirectoryContents(destinationFolderPath, true, false);

        % get name of unzipped folder
        folder = setdiff({newDirectoryContents.name}, {oldDirectoryContents.name});

        % setdiff returns a cell so extract string in cell
        folder = folder{1};
        
        % get folder path in destination folder
        folderPath = fullfile(destinationFolderPath, folder);
    else
        % get system temporary directoryContents
        temporaryFilePath = tempname;

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
        movefile(fullfile(temporaryFilePath, folder), destinationFolderPath);

        % clean up
        rmdir(temporaryFilePath, 's');
    end

end