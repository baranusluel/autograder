%% gradeStudentSubmissions Runs, grades, and generates feedback for each student
%
%   gradebook = gradeStudentSubmissions(gradebook, rubric)
%
%   Inputs:
%       gradebook (struct)
%           - structure representing the gradebook and contains students
%       rubric (struct)
%           - structure representing the rubric and contains details
%           regarding the problems and test cases
%       timeout log handle (double)
%           - text file handle for printing to timeout log
%
%   Output(s):
%       gradebook (struct)
%           - the updated structure with the results and grades for the
%           test cases
%
%   Description:
%       Runs, grades, and generates feedback for each student
function gradebook = gradeStudentSubmissions(gradebook, rubric)

    gradebook.timeout = struct('isTimeout', false, 'studentIndices' , []);
                           
    for ndxStudent = length(gradebook.students):-1:1
        p = gcp;
        parfeval(p,@fclose,0, 'all'); fclose('all'); % Clean Up after Each Student
        parfeval(p,@close,0, 'all'); close('all');
        student = gradebook.students(length(gradebook.students) - ndxStudent + 1);
        student = runSubmission(rubric, student);
        student = gradeSubmission(rubric, student);
        student = getFeedback(rubric, student, gradebook.folderPaths.homework);
        students(ndxStudent) = student;
        fprintf('\t%s, %s, %0.2f\n', student.lastName, student.firstName, student.grade);
    end
    gradebook.students = students(end:-1:1);

end