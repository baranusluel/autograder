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
function [] = runStudent(studentFilePath, rubricZipFilePath, isResubmission)

    clc;
    close all;

    % start timer
    tstart = tic;

    % get the current directory (to go back to after running)
    currentDirectory = pwd;

    % add the autograder folder to the MATLAB path
    autograderFolderPath = fileparts(mfilename('fullpath'));
    addpath(autograderFolderPath);

    % get rubric
    disp('Getting rubric...');
    rubric = getRubric(rubricZipFilePath, studentFilePath, isResubmission);

    % grade student submissions
    disp('Grading student submissions...');
    gradeStudentSubmission(studentFilePath, rubric);

   % autograder run time
    toc(tstart)

    % upload files to server
    uploadStudent(studentDirectory, rubric);

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

    % total run time
    toc(tstart);

end