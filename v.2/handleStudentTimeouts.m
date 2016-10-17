function gradebook = handleStudentTimeouts(gradebook, rubric)
    for ndxStudent = gradebook.timeout.studentIndices
        student = gradebook(ndxStudent);
    end
end