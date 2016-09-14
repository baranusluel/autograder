% preset variables
gradingFolderPath     = '/Users/jimmynguyen/Dropbox/georgiaTech/2016/fall/cs1371/grading/hw03/submission';
homeworkZipFileName   = 'bulk_download.zip';
rubricZipFileName     = 'rubric.zip';
destinationFolderName = 'grading';

% get full paths
homeworkZipFilePath   = fullfile(gradingFolderPath, homeworkZipFileName);
rubricZipFilePath     = fullfile(gradingFolderPath, rubricZipFileName);
destinationFolderPath = fullfile(gradingFolderPath, destinationFolderName);

% delete destination folder if it exists
if exist(destinationFolderPath, 'dir')
    rmdir(destinationFolderPath, 's');
end

% call autograder
runAutograder(homeworkZipFilePath, rubricZipFilePath, destinationFolderPath);