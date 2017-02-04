homeworkZipFilePath   = 'C:\Users\suba\Documents\Gatech\CS1371_TA\TechTeam\GradingSpring17\HW1_Debug\hw1_bulk_download.zip';
rubricZipFilePath     = 'C:\Users\suba\Documents\Gatech\CS1371_TA\TechTeam\GradingSpring17\HW1_Debug\hw1Grader.zip';
destinationFolderPath = 'C:\Users\suba\Documents\Gatech\CS1371_TA\TechTeam\GradingSpring17\HW1_Debug\hw1Dest';
runAutograder(homeworkZipFilePath ,rubricZipFilePath , destinationFolderPath );

%% Remove Mat files
% load('autograder.mat');
% curr = pwd;
% for i = 1:length(gradebook.students)
%    loc = gradebook.students(i).folderPaths.submissionAttachments;
%    cd(loc);
%    system('del /q /f *.mat');
%    cd ..;
% end

%% Display Grade Distribution
% for i = 1:length(gradebook.students)
% mask(i) = length(dir(gradebook.students(i).folderPaths.submissionAttachments)) > 2;
% end
% grades= [gradebook.students.grade];
% median(grades(mask));
% hist(grades);

%% Clean Up
% system('rmdir "C:\Users\suba\Documents\Gatech\CS1371_TA\TechTeam\GradingSpring17\HW1\hw1Dest" /s /q');
% system('mkdir "C:\Users\suba\Documents\Gatech\CS1371_TA\TechTeam\GradingSpring17\HW1\hw1Dest"');
