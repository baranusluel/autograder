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
function gradebook = gradeStudentSubmissions(gradebook, rubric, timeoutLogH)

    gradebook.timeout = struct('isTimeout', false,...
                               'studentIndices' , []);
    for ndxStudent = length(gradebook.students):-1:1
        student = gradebook.students(length(gradebook.students) - ndxStudent + 1);

        if isVerbose()
            fprintf('\t%s\n', student.ID);%lastName, student.firstName);
        end

        student = runSubmission(rubric, student, timeoutLogH);
%         % handle timeout
%         if student.timeout.isTimeout
%             gradebook.timeout.isTimeout = true;
%             gradebook.timeout.studentIndices(end+1) = ndxStudent;
%             fields = setdiff(fieldnames(students), fieldnames(student));
%             for ndxField = 1:length(fields)
%                 field = fields{ndxField};
%                 student.(field) = [];
%             end
%         else
            student = gradeSubmission(rubric, student);
            student = getFeedback(rubric, student, gradebook.folderPaths.homework);
%         end

        students(ndxStudent) = student;
    end
    gradebook.students = students(end:-1:1);

end