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
function [] = runAutograder(varargin)

    delete(gcp('nocreate'));
    clc; close all; fclose all;
    if nargin == 3
        homeworkZipFilePath   = varargin{1};
        rubricZipFilePath     = varargin{2};
        destinationFolderPath = varargin{3};
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
            disp('Clearing destination folder');
            if ~isFolderEmpty(destinationFolderPath)
                cd(destinationFolderPath);
                cd('..');
                system(['rmdir /s /q ' destinationFolderPath]);
                mkdir(destinationFolderPath);
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
        addpath(rubric.addpath.overridenFunctionsFolderPath);
        gradebook = gradeStudentSubmissions(gradebook, rubric);
        rmpath(rubric.addpath.overridenFunctionsFolderPath);

       % write grades.csv
        disp('Writing grades to grades.csv...');
        writeGradesCsv(gradebook);

        % save rubric and gradebook in case we want to use it later
        disp('Saving gradebook and rubric to autograder.mat...');
        save(fullfile(destinationFolderPath, 'autograder.mat'), 'rubric', 'gradebook');

%% Remove Mat files
        currDir = pwd;
        cd(destinationFolderPath)
        load('autograder.mat');
        system('del /q /f *.mat *.txt *.xls *.jpg');
        cd(currDir);

%% Display Grades
        mask = false(1, length(gradebook.students));
        for i = 1:length(gradebook.students)
            mask(i) = length(dir(gradebook.students(i).folderPaths.submissionAttachments)) > 3;
        end
        grades= [gradebook.students.grade];
        median(grades(mask));
        figure; hist(grades(mask));
        output = input('Continue? Enter with Quotes (''Y'' or ''N'')\n');
        if ~strcmp(output,'Y')
            return;
        end
%% Upload and Zip   
        % upload files to server
%            uploadFilesToServer(gradebook, rubric);

        % delete all .m files for t-square upload
        cd(destinationFolderPath);
        system('del /s /q /f *.m');
        cd(currDir);
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
        % remove the autograder folder from the MATLAB path
        rmpath(autograderFolderPath);
        % remote all folders added to the MATLAB path
        pathsToRemove = fieldnames(rubric.addpath);
        for ndx = 1:length(pathsToRemove)
            rmpath(rubric.addpath.(pathsToRemove{ndx}));
        end
        % go back to the starting directory
        cd(currentDirectory);
        % close parallel pool if open (opened when running student submissions)
        delete(gcp('nocreate'));
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
end