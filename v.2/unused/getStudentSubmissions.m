function gradebook = getStudentSubmissions(gradebook)

    for ndxStudent = 1:length(gradebook)
        student = gradebook(ndxStudent);
        submissionFolderPath = fullfile(student.StudentFolder, 'Submission attachment(s)');
        gradebook(ndxStudent).FunctionHandles = getFunctionHandles(submissionFolderPath);
    end

end