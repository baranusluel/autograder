function newGradebook = generateFeedbackFiles(gradebook, rubric, homeworkFolderPath)
    newGradebook = struct([]);
    for ndxStudent = 1:length(gradebook)
        student = gradebook(ndxStudent);

        student = getFeedback(rubric, student);

        newGradebook = [newGradebook, student];
    end
end