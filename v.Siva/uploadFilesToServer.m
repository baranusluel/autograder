function uploadFilesToServer(gradebook, rubric)

% upload student files to server
disp('Uploading student files to server...');
uploadStudentFilesToServer(gradebook);

% upload homework generator files to server
disp('Uploading homework generator files to server...');
uploadHomeworkGeneratorFilesToServer(rubric, gradebook.homeworkNumber, gradebook.isResubmission);

end