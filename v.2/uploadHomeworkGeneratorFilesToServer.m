function uploadHomeworkGeneratorFilesToServer(rubric, homeworkNumber, isResubmission)
    paths = uploadFile('p');

    % upload student rubric files (_soln.p, pdf)
    p_files = getDirectoryContents(fullfile(rubric.folderPaths.rubricStudent, '*.p'), false, true);
    pdf_files = getDirectoryContents(fullfile(rubric.folderPaths.rubricStudent, '*.pdf'), false, true);
    files = [p_files, pdf_files];
    for ndxFile = 1:length(files)
        file = files(ndxFile);
        local_file_path  = fullfile(rubric.folderPaths.rubricStudent, file.name);
        remote_file_path = fullfile(paths.SOLUTIONS, sprintf('Homework%d', homeworkNumber));
    end

    % TODO: upload supporting files

    % get homework number string
    homeworkNumber = num2str(homeworkNumber);
    if length(homeworkNumber) <= 1
        homeworkNumber = sprintf('0%s', homeworkNumber);
    end

    % upload rubric*.json
    local_file_path  = fullfile(rubric.folderPaths.rubric, rubric.filePaths.rubricFileName);
    remote_file_name = sprintf('homework%sRubric', homeworkNumber);
    if isResubmission
        remote_file_name = sprintf('%s_resub.json', remote_file_name);
    else
        remote_file_name = sprintf('%s.json', remote_file_name);
    end
    remote_file_path = fullfile(paths.RUBRICS, remote_file_name);
    uploadFile(local_file_path, remote_file_path);

end