function gradebook = runStudentSubmissions(gradebook, rubric)
    students = struct([]);
    for ndxStudent = 1:length(gradebook.students)
        student = gradebook.students(ndxStudent);

        if isVerbose()
            fprintf('%s, %s\n', student.LastName, student.FirstName);
        end

        student = runStudentSubmission(rubric, student);
        
        students = [students, student];
    end
    gradebook.students = students;
end