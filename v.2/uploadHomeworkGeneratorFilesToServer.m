function uploadHomeworkGeneratorFilesToServer(rubric, homeworkNumber, isResubmission)
    settings = getSettings();
    paths = uploadFile('p');
    channel = [];
    sftp_client = [];

    % upload student rubric files (_soln.p, .pdf)
    if ~isResubmission
        rubric_folder_path = fileparts(rubric.folderPaths.rubric);
        rubric_student_folder_path = fullfile(rubric_folder_path, settings.folderNames.RUBRIC_STUDENT);
        p_files = getDirectoryContents(fullfile(rubric_student_folder_path, '*.p'), false, true);
        pdf_files = getDirectoryContents(fullfile(rubric_student_folder_path, '*.pdf'), false, true);
        files = [p_files; pdf_files];
        for ndxFile = 1:length(files)
            file = files(ndxFile);
            local_file_path  = fullfile(rubric_student_folder_path, file.name);
            remote_file_path = fullfile(paths.SOLUTIONS, sprintf('Homework%d', homeworkNumber));
            [channel, sftp_client] = uploadFile(local_file_path, remote_file_path, channel, sftp_client);
        end
    end

    % upload supporting files zip
    if isResubmission
        supporting_files_zip_file_name = 'Supporting Files Resub.zip';
    else
        supporting_files_zip_file_name = 'Supporting Files.zip';
    end
    local_supporting_files_zip_file_path = fullfile(rubric.folderPaths.rubric, supporting_files_zip_file_name);
    remote_supporting_files_zip_file_path = fullfile(paths.SOLUTIONS, sprintf('Homework%d', homeworkNumber), supporting_files_zip_file_name);
    zip(local_supporting_files_zip_file_path, rubric.addpath.supportingFiles);
    [channel, sftp_client] = uploadFile(local_supporting_files_zip_file_path, remote_supporting_files_zip_file_path, channel, sftp_client);

    % get homework number string
    homeworkNumber = num2str(homeworkNumber);
    if length(homeworkNumber) <= 1
        homeworkNumber = sprintf('0%s', homeworkNumber);
    end

    % upload rubric*.json
    local_file_path  = fullfile(rubric.folderPaths.rubric, rubric.filePaths.rubricFileName);
    remote_file_name = sprintf('hw%sRubric', homeworkNumber);
    if isResubmission
        remote_file_name = sprintf('%s_resub.json', remote_file_name);
    else
        remote_file_name = sprintf('%s.json', remote_file_name);
    end
    remote_file_path = fullfile(paths.RUBRICS, remote_file_name);
    [channel, sftp_client] = uploadFile(local_file_path, remote_file_path, channel, sftp_client);

    sftp_client.close();
    channel.close();
end