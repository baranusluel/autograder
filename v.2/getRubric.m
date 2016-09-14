%% getRubric Gets the rubric to run the homework
%
%   rubric = getRubric(rubricZipFilePath, destinationFolderPath)
%
%   Inputs:
%       rubricZipFilePath (char)
%           - path to the rubric .zip file
%       destinationFolderPath (char)
%           - path to the working directory
%
%   Output:
%       rubric (struct)
%           - a struct containing the details for the problems for the
%           current homework (test cases, points, solutions, etc.)
%
%   Description:
%       Unzips the rubric .zip file, parses the rubric.json file, converts
%       supporting files to .mat, and runs the solutions
function rubric = getRubric(rubricZipFilePath, destinationFolderPath)
    % get settings
    settings = getSettings();

    % throw error if the destination folder is not empty
    if exist(destinationFolderPath, 'dir') && isFolderEmpty(destinationFolderPath)
        error('The destination folder must be empty');
    end

    % create destination folder
    mkdir(destinationFolderPath);

    % unzip zip file
    rubricFolderPath = unzipFile(rubricZipFilePath, destinationFolderPath);

    % load rubric
    rubricJSONFilePath = fullfile(rubricFolderPath, settings.fileNames.RUBRIC_JSON);
    rubric = loadRubric(rubricJSONFilePath);
    rubric.folderPaths.rubric = rubricFolderPath;

    % convert supporting files to .mat
    rubric.addpath.supportingFiles = fullfile(rubricFolderPath, settings.folderNames.SUPPORTING_FILES);
    convertSupportingFiles(rubric.addpath.supportingFiles); 
    
    % add supporting files to MATLAB path
    addpath(rubric.addpath.supportingFiles);

    % get solution output
    rubric.folderPaths.solutions = fullfile(rubricFolderPath, settings.folderNames.SOLUTIONS);
    rubric = runSolutions(rubric);
end