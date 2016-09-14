function rubric = autoGraderSetup
    %% make sure you're in the MINOS folder/files
    answer = questdlg('Are you in the MINOS folder? We want to copy all the useful files into the Homework folder.');
    if ~strcmp(answer, 'Yes')
        error('Make sure you''re in the right directory, silly!')
    end

    %% choose the rubric you want to use
    disp('Select rubric...');
    [rubric, rubric_dir] = uigetfile('*.txt', 'Please choose the rubric');
    disp('Rubric selected.');
    
    %% choose folder you want to extract and where do you want to put it
    % also need to unzip the file into the destination folder
    % change to previous folder because that's what other things do
    currentDir = pwd;
    cd (rubric_dir)
    disp('Select bulk_download folder...');
    [bulk_name, path, ~] = uigetfile('*.zip', 'Select the bulk_download folder');
    disp('bulk_download folder selected.');
    cd(path)
    
    disp('Select where you want to put the extracted folder...');
    dest = uigetdir('Select where you want to put the extracted file');
    disp('Selected.');
    
    disp('Unzipping pants, please hold...')
    unzip(fullfile(path, bulk_name), dest);
    
    %% select the homework folder to copy all the files into it
    cd(dest)
    disp('Select the extracted homework folder...');
    hdest = uigetdir('Select the extracted homework folder');
    disp('Homework folder selected.');
    cd(currentDir)
    disp('Copying over necessary files...')
    copyfile('*.m', hdest);
    copyfile([rubric_dir filesep rubric], hdest);
    cd(hdest)
    disp('Done.');
    
    %% get solution files
    mkdir Solutions
    disp('Select solution files...');
    [solution_files, spath, ~] = uigetfile('Select the solution files', 'MultiSelect', 'on');
    if ~iscell(solution_files)
        solution_files = {solution_files};
    end
    for x = 1:length(solution_files)
        copyfile([spath filesep solution_files{x}], ['.' filesep 'Solutions']);
    end
    disp('Copied solution files.');
    
    %% get copy files files
    mkdir 'Copy Files'
    disp('Select copy files...');
    [copy_files, cpath, ~] = uigetfile('Select the Copy Files', 'MultiSelect', 'on');
    if ~iscell(copy_files)
        copy_files = {copy_files};
    end
    for x = 1:length(copy_files)
        copyfile([cpath filesep copy_files{x}], ['.' filesep 'Copy Files']);
    end
    disp('Copied copy files.');
    
end