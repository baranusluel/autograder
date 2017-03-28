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
function gradebook = gradeStudentSubmission(rubric)

    for ndxStudent = length(gradebook.students):-1:1
        student = gradebook.students(length(gradebook.students) - ndxStudent + 1);

        if isVerbose()
            fprintf('\t%s, %s\n', student.lastName, student.firstName);
        end

        student = runSubmission(rubric, student);
        student = gradeSubmission(rubric, student);
        student = getFeedback(rubric, student, gradebook.folderPaths.homework);
    end
end