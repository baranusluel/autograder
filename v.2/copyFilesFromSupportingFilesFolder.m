function copyFilesFromSupportingFilesFolder(supportingFilesFolderPath, supportingFiles, destinationFolderPath)

    % get possible img format extensions
    possibleImageExtensions = imformats;
    possibleImageExtensions = [possibleImageExtensions.ext];
        
    % copy files from the supporting files folder to the student folder for the current problem
    for ndxSupportingFile = 1:length(supportingFiles)
        filename = supportingFiles{ndxSupportingFile};
        
        % get file extension
        [~, ~, extension] = fileparts(filename);
        extension         = strtok(extension,'.');
        %{
        switch extension
            case {'xls','xlsx'}
                [filepath, filename, extension] = fileparts(filename);
                filename = fullfile(filepath, [filename '_' extension(2:end) '.mat']);
            case possibleImageExtensions
                [filepath, filename, extension] = fileparts(filename);
                filename = fullfile(filepath, [filename '_' extension(2:end) '.mat']);
            otherwise
        end
        %}
        copyfile(fullfile(supportingFilesFolderPath,...
                          filename),...
                 destinationFolderPath);
    end
    
end