%% convertSupportingFiles Converts supporting files to .mat
%
%   convertSupportingFiles(folderPath)
%
%   Input:
%       folderPath (char)
%           - path to the supporting files folder
%
%   Output:
%       NONE
%
%   Description:
%       Converts files in the supporting files folder to .mat
function convertSupportingFiles(folderPath)

    if exist(folderPath,'dir') && ~isFolderEmpty(folderPath)

        % get directory contents
        directory = getDirectoryContents(folderPath, false, true);

        % get possible img format extensions
        possibleImageExtensions = imformats;
        possibleImageExtensions = [possibleImageExtensions.ext];

        % iterate through supporting files and generate .mat files
        for ndx = 1:length(directory)
            % get file extension
            [~, ~, extension] = fileparts(directory(ndx).name);
            extension         = strtok(extension,'.');

            switch extension
                case {'xls','xlsx'}
                    xls2mat(fullfile(folderPath, directory(ndx).name));
                case possibleImageExtensions
                    img2mat(fullfile(folderPath, directory(ndx).name));
            end
        end
    end

end