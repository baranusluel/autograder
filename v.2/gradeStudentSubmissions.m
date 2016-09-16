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
%
%   Output(s):
%       gradebook (struct)
%           - the updated structure with the results and grades for the
%           test cases
%
%   Description:
%       Runs, grades, and generates feedback for each student
function gradebook = gradeStudentSubmissions(gradebook, rubric)

    for ndxStudent = length(gradebook.students):-1:1
        student = gradebook.students(length(gradebook.students) - ndxStudent + 1);

        if isVerbose()
            fprintf('\t%s, %s\n', student.lastName, student.firstName);
        end

        student = runSubmission(rubric, student);
        student = gradeSubmission(rubric, student);
        student = getFeedback(rubric, student, gradebook.folderPaths.homework);
        uploadStudentFilesToServer(student, gradebook.homeworkNumber, gradebook.isResubmission);

        students(ndxStudent) = student;
    end
    gradebook.students = students(end:-1:1);

end