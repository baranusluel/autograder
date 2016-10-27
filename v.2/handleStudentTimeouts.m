function gradebook = handleStudentTimeouts(gradebook, rubric)
    for ndxStudent = gradebook.timeout.studentIndices
        student = gradebook.students(ndxStudent);
    end
end