%% getGradebook Gets the gradebook
%
%   gradebook = getGradebook(homeworkZipFilePath, destinationFolderPath)
%
%   Inputs:
%       homeworkZipFilePath (char)
%           - path to the homework .zip file
%       destinationFolderPath (char)
%           - path to the working directory
%
%   Output:
%       gradebook (struct)
%           - a struct containing the students
%
%   Description:
%       Unzips the homework .zip file, reads the grades.csv file, and
%       initializes the gradebook
function gradebook = getGradebook(homeworkZipFilePath, destinationFolderPath)
    % unzip zip file
    gradebook.folderPaths.homework = unzipFile(homeworkZipFilePath, destinationFolderPath);

    % get relevant homework information
    [~, homeworkFolderName] = fileparts(gradebook.folderPaths.homework);
    homeworkNumber = strtok(homeworkFolderName, '-');
    gradebook.homeworkNumber = str2double(homeworkNumber(homeworkNumber >= '0' & homeworkNumber <= '9'));
    gradebook.isResubmission = ~isempty(strfind(lower(gradebook.folderPaths.homework), 'resubmission'));

    settings = getSettings();
    gradebook.filePaths.gradesCsv = fullfile(gradebook.folderPaths.homework, settings.fileNames.GRADES_CSV);

    % open grades.csv
    gradebookTemplate = readGradesCsv(gradebook.filePaths.gradesCsv);

    % check if format of grades.csv changed
    [isFormatDifferent, columnIndices] = isGradesCsvFormatDifferent(gradebookTemplate);
    if isFormatDifferent
        % throw error
        error('The format of the ''grades.csv'' file is different than expected.');
    end

    % remove unrelated rows
    gradebookTemplate(1:3,:) = [];

    % define columns
    displayIdColumn = columnIndices(1);
    idColumn        = columnIndices(2);
    lastNameColumn  = columnIndices(3);
    firstNameColumn = columnIndices(4);
    gradeColumn     = columnIndices(5);

    % get student ids from folders
    [studentIdsFromFolders,studentFolders] = getStudentIds(gradebook.folderPaths.homework);
    [sortedStudentIdsFromFolders,~] = sort(studentIdsFromFolders);

    % initialize gradebook struct
    gradebook.students = struct(...
        'displayID'  , gradebookTemplate(:,displayIdColumn),...
        'id'         , gradebookTemplate(:,idColumn),...
        'firstName'  , cellfun(@strtrim,gradebookTemplate(:,firstNameColumn),'UniformOutput',false),...
        'lastName'   , gradebookTemplate(:,lastNameColumn),...
        'grade'      , gradebookTemplate(:,gradeColumn),...
        'folderPaths', cellfun(@(folderName)(struct('submissionAttachments', fullfile(gradebook.folderPaths.homework, folderName, settings.folderNames.SUBMISSION_ATTACHMENTS), 'feedbackAttachments', fullfile(gradebook.folderPaths.homework, folderName, settings.folderNames.FEEDBACK_ATTACHMENTS))), {studentFolders.name}, 'UniformOutput', false)'...
    );

    % get student ids from grades.csv
    studentIdsFromGradesCsv = gradebookTemplate(:, idColumn);
    [sortedStudentIdsFromGradesCsv,~] = sort(studentIdsFromGradesCsv);

    % check if the student ids from folders and grades.csv file matches
    if ~isequal(sortedStudentIdsFromFolders(:),sortedStudentIdsFromGradesCsv(:))
        error('Student IDs from the folders and the ''grades.csv'' file do not match.');
    end
end