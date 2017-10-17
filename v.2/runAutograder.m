%% runAutograder Runs the CS 1371 autograder
%
%   [] = runAutograder()
%
%   Inputs:
%       NONE
%
%   Outputs:
%       NONE
%
%   Description:
%       Runs the CS 1371 autograder
%
%   How to run:
%
function [] = runAutograder(homeworkZipFilePath, rubricZipFilePath, destinationFolderPath)

    clc;
    close all;
    userFigureSetting = get(0,'DefaultFigureVisible');
    set(0,'DefaultFigureVisible','off');
    
    isCurrent = ver('MATLAB');
    if str2double(isCurrent.Release(3:6)) > 2016
        if isstring(homeworkZipFilePath)
            homeworkZipFilePath = homeworkZipFilePath.char;
        end
        if isstring(rubricZipFilePath)
            rubricZipFilePath = rubricZipFilePath.char;
        end
        if isstring(destinationFolderPath)
            destinationFolderPath = destinationFolderPath.char;
        end
        if ispc
            if contains(path, [getenv('USERPROFILE') '\Documents\MATLAB'])
                rmpath([getenv('USERPROFILE') '\Documents\MATLAB\']);
                isDoc = true;
            else
                isDoc = false;
            end
        elseif ismac || isunix
            if contains(path, [cd(cd('~')) '/Documents/MATLAB'])
                isDoc = true;
                rmpath('~/Documents/MATLAB/');
            else
                isDoc = false;
            end
        end
    else
        isDoc = true;
    end
    try
        % getting homework .zip file
        if ~exist('homeworkZipFilePath', 'var') || ~exist(homeworkZipFilePath, 'file')
            isValid = false;
            while ~isValid
                [homeworkZipFileName, homeworkZipParentFolderPath] = uigetfile('*.zip', 'Select the homework .zip file');
                if isequal(homeworkZipFileName,0) || isequal(homeworkZipParentFolderPath,0)
                    choice = questdlg('You did not select a file. Would you like to continue grading?', ...
                                      '', ...
                                      'Yes');
                    switch choice
                        case {'No', 'Cancel'}
                            error('The autograder has stopped');
                        case 'Yes'
                            % continue
                    end
                else
                    isValid = true;
                    homeworkZipFilePath = fullfile(homeworkZipParentFolderPath, homeworkZipFileName);
                end
            end
        end

        % getting rubric .zip file
        if ~exist('rubricZipFilePath', 'var') || ~exist(rubricZipFilePath, 'file')
            isValid = false;
            while ~isValid
                [rubricZipFileName, rubricZipParentFolderPath] = uigetfile('*.zip', 'Select the rubric .zip file');
                if isequal(rubricZipFileName,0) || isequal(rubricZipParentFolderPath,0)
                    choice = questdlg('You did not select a file. Would you like to continue grading?', ...
                                      '', ...
                                      'Yes');
                    switch choice
                        case {'No', 'Cancel'}
                            error('The autograder has stopped');
                        case 'Yes'
                            % continue
                    end
                else
                    isValid = true;
                    rubricZipFilePath = fullfile(rubricZipParentFolderPath, rubricZipFileName);
                end
            end
        end

        % getting destination folder
        if ~exist('destinationFolderPath', 'var')
            isValid = false;
            while ~isValid
                destinationFolderPath = uigetdir('', 'Select the destination folder');
                if isequal(destinationFolderPath,0)
                    choice = questdlg('You did not select a folder. Would you like to continue grading?', ...
                                      '', ...
                                      'Yes');
                    switch choice
                        case {'No', 'Cancel'}
                            error('The autograder has stopped');
                        case 'Yes'
                            % continue
                    end
                else
                    isValid = true;
                end
            end
        end

        try

            % start timer
            tstart = tic;

            % get the current directory (to go back to after running)
            currentDirectory = pwd;

            % add the autograder folder to the MATLAB path
            autograderFolderPath = fileparts(mfilename('fullpath'));
            addpath(autograderFolderPath);

            % create destination folder if it doesn't exist
            if ~exist(destinationFolderPath, 'dir')
                mkdir(destinationFolderPath);
            else
                % throw error if the destination folder is not empty
                if ~isFolderEmpty(destinationFolderPath)
                    error('The destination folder must be empty');
                end
            end

            % get gradebook
            disp('Getting gradebook...');
            gradebook = getGradebook(homeworkZipFilePath, destinationFolderPath);

            % get rubric
            disp('Getting rubric...');
            rubric = getRubric(rubricZipFilePath, destinationFolderPath, gradebook.isResubmission);

            % grade student submissions
            disp('Grading student submissions...');
            timeoutLogH = fopen([destinationFolderPath filesep 'timeoutLog.txt'], 'wt');
            addpath(rubric.addpath.overridenFunctionsFolderPath);
            fprintf(timeoutLogH, 'Student Function Timeouts:\n\n');
            gradebook = gradeStudentSubmissions(gradebook, rubric, timeoutLogH);
            fclose(timeoutLogH);
            rmpath(rubric.addpath.overridenFunctionsFolderPath);

%             % handle timeout
%             if gradebook.timeout.isTimeout
%                 disp('Sad bois... Found students with timeouts...');
%                 dbstop in handleStudentTimeouts at 1;
%                 gradebook = handleStudentTimeouts(gradebook, rubric);
%             else
%                 disp('Good news! There were no timeouts!')
%             end

           % write grades.csv
            disp('Writing grades to grades.csv...');
            writeGradesCsv(gradebook);

            % save rubric and gradebook in case we want to use it later
            disp('Saving gradebook and rubric to autograder.mat...');
            save(fullfile(destinationFolderPath, 'autograder.mat'), 'rubric', 'gradebook');

            % zip the graded homework folder for upload to t-square
            disp('Zipping homework upload folder...');
            outputZipFilePath = [gradebook.folderPaths.homework, '.zip'];
            if exist(outputZipFilePath, 'file')
                % delete the file if it already exists
                delete(outputZipFilePath);
            end
            zip(outputZipFilePath, gradebook.folderPaths.homework);

            % autograder run time
            toc(tstart)
            % restore Documents
            if isDoc && ispc
                addpath([getenv('USERPROFILE') '\Documents\MATLAB\']);
            elseif isDoc && (ismac || isunix)
                addpath('~/Documents/MATLAB/');
            end
            set(0,'DefaultFigureVisible',userFigureSetting);
            % upload files to server (Deprecated)
            % uploadFilesToServer(gradebook, rubric);

            % remove the autograder folder from the MATLAB path
            rmpath(autograderFolderPath);

            % remove all folders added to the MATLAB path
            pathsToRemove = fieldnames(rubric.addpath);
            for ndx = 1:length(pathsToRemove)
                rmpath(rubric.addpath.(pathsToRemove{ndx}));
            end

            % go back to the starting directory
            cd(currentDirectory);

            % close parallel pool if open (opened when running student submissions)
            delete(gcp('nocreate'));

            % total run time
            toc(tstart);

        catch ME

            % display error message
            disp(ME.message);

            % display stack
            for ndxStack = 1:length(ME.stack)
                disp(ME.stack(ndxStack));
            end

            % remove the autograder folder from the MATLAB path
            rmpath(autograderFolderPath);

            % go back to the starting directory
            cd(currentDirectory);

            % try to remove all folders added to the MATLAB path
            try
                % remove overridenFunctions from the MATLAB path
                rmpath(overridenFunctionsFolderPath);

                pathsToRemove = fieldnames(rubric.addpath);
                for ndx = 1:length(pathsToRemove)
                    rmpath(rubric.addpath.(pathsToRemove{ndx}));
                end
            catch
                % if it errors, that means nothing was added to the MATLAB path
                % so do nothing
            end

        end
    catch ME
        disp(ME.message);
    end
    % restore Documents
    if isDoc && ispc
        addpath([getenv('USERPROFILE') '\Documents\MATLAB\']);
    elseif isDoc && (ismac || isunix)
        addpath('~/Documents/MATLAB/');
    end
    set(0,'DefaultFigureVisible',userFigureSetting);
end