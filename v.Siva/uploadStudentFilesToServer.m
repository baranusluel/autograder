%% uploadStudentFilesToServer Uploads student files to cs1371.gatech.edu server
%
%   uploadStudentFilesToRegradeWebsite(gradebook)
%
%   Inputs:
%       gradebook (struct)
%           - structure representing the gradebook
%
%   Outputs:
%       NONE
%
%   Description:
%       Uploads student submission attachments and feedback attachment files to
%       cs1371.gatech.edu server
function uploadStudentFilesToServer(gradebook)
    % get struct of remote root paths
    paths = uploadFile('p');

    homeworkNumber = gradebook.homeworkNumber;
    isResubmission = gradebook.isResubmission;

    for ndxStudent = 1:length(gradebook.students)
        student = gradebook.students(ndxStudent);

        if isVerbose()
            fprintf('\t%s, %s\n', student.lastName, student.firstName);
        end

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
%             try
                uploadFile(file_path, remote_file_path);
%             catch ME
%                 % if an error occurs, ignore for now (probably should write to some error file or something...)
%                 disp(ME.message);
%             end
        end

        %% upload feedback attachment files

        % get student feedback file(s)
        directoryContents = getDirectoryContents(student.folderPaths.feedbackAttachments, false, true);
        
        % get feedback attachments folder name
        [student_folder_path, feedback_attachments_folder_name] = fileparts(student.folderPaths.feedbackAttachments);

        % if the the student did not submit any files
        if isempty(remote_file_path)
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
            remote_file_path = fullfile(paths.HOMEWORKS, homework_folder_name, student_folder_name, feedback_attachments_folder_name);
        else
            % remove the submission attachments folder name from the remote file path
            remote_file_path = fileparts(remote_file_path);

            % get remote file path
            remote_file_path = fullfile(remote_file_path, feedback_attachments_folder_name);
        end

        % for each file, upload
        for ndxFile = 1:length(directoryContents)
            file = directoryContents(ndxFile);

            % get local file path
            file_path = fullfile(student.folderPaths.feedbackAttachments, file.name);

            % upload file to server via sftp
%             try
                uploadFile(file_path, remote_file_path);
%             catch ME
%                 % if an error occurs, ignore for now (probably should write to some error file or something...)
%                 disp(ME.message);
%             end
        end
    end
end