%% uploadStudentFilesToServer Uploads student files to cs1371.gatech.edu server
%
%   uploadStudentFilesToRegradeWebsite(student, homeworkNumber, isResubmission)
%
%   Inputs:
%       student (struct)
%           - structure representing the student
%       homeworkNumber (double)
%           - homework number
%       isResubmission (logical)
%           - whether or not the homework being graded is the original or the resub
%
%   Outputs:
%       NONE
%
%   Description:
%       Uploads student submission attachments and feedback attachment files to
%       cs1371.gatech.edu server
function uploadStudentFilesToServer(student, homeworkNumber, isResubmission)
    % get struct of remote root paths
    paths = uploadFile('p');

    %% upload submission attachment files

    % get student submission files
    directoryContents = getDirectoryContents(student.folderPaths.submissionAttachments, false, true);

    % for each file, upload
    remote_file_path = '';
    for ndxFile = 1:length(directoryContents)
        file = directoryContents(ndxFile);

        % get local file path
        file_path = fullfile(student.folderPaths.submissionAttachments, file.name);

        % only need to compute the remote file path once
        if isempty(remote_file_path)
            % get student folder name
            [student_folder_path, submission_attachments_folder_name] = fileparts(student.folderPaths.submissionAttachments);
            [~, student_folder_name] = fileparts(student_folder_path);

            % get homework folder name
            homeworkNumber = num2str(homeworkNumber);
            if length(homeworkNumber) <= 1
                homeworkNumber = sprintf('0%s', homeworkNumber);
            end
            homework_folder_name = sprintf('homework%s', homeworkNumber);
            if isResubmission
                homework_folder_name = sprintf('%s_resub', homework_folder_name);
            end

            % get remote file path
            remote_file_path = fullfile(paths.HOMEWORKS, homework_folder_name, student_folder_name, submission_attachments_folder_name);
        end

        % upload file to server via sftp
        try
            uploadFile(file_path, remote_file_path);
        catch
            % if an error occurs, ignore for now (probably should write to some error file or something...)
        end
    end

    %% upload feedback attachment files

    % get student feedback file(s)
    directoryContents = getDirectoryContents(student.folderPaths.feedbackAttachments, false, true);

    % get feedback attachments folder name
    [~, feedback_attachments_folder_name] = fileparts(student.folderPaths.feedbackAttachments);

    % remove the submission attachments folder name from the remote file path
    remote_file_path = fileparts(remote_file_path);

    % get remote file path
    remote_file_path = fullfile(remote_file_path, feedback_attachments_folder_name);

    % for each file, upload
    for ndxFile = 1:length(directoryContents)
        file = directoryContents(ndxFile);

        % get local file path
        file_path = fullfile(student.folderPaths.feedbackAttachments, file.name);

        % upload file to server via sftp
        try
            uploadFile(file_path, remote_file_path);
        catch
            % if an error occurs, ignore for now (probably should write to some error file or something...)
        end
    end
end