%% getFeedback Gets the feedback for the given student and generates the feedback file
%
%   student = getFeedback(rubric, student, homeworkFolderPath)
%
%   Inputs:
%       rubric (struct)
%           - structure representing the rubric and contains details
%           regarding the problems and test cases
%       student (struct)
%           - structure representing a student
%       homeworkFolderPath (char)
%           - path to the folder containing the student folders and
%           grades.csv file
%
%   Output:
%       student (struct)
%           - the updated structure with the feedback
%
%   Description:
%       Generates feedback for the given student
function student = getFeedback(rubric, student, homeworkFolderPath)

    % initialize student feedback
    student.feedback = '<div style="font-family: Tahoma, Verdana, Segoe, sans-serif;">';

    % concatenate styling
    student.feedback = sprintf('%s<style>p {font-size:12px}</style>', student.feedback);

    % concatenate homework number and description
    [~, homeworkFolderName] = fileparts(homeworkFolderPath);
    student.feedback = sprintf('%s<h1>%s</h1>', student.feedback, homeworkFolderName);

    % concatenate student name
    student.feedback = sprintf('%s<p>%s</p>', student.feedback, student.ID);

    % open grade table
    student.feedback = sprintf('%s<table border="1" style="border-collapse:collapse">', student.feedback);

    % add table header
    student.feedback = sprintf('%s<tr><td style="padding:5px"><p><strong>Problem</strong></p></td><td style="text-align:right;padding:5px"><p><strong>Points Received</strong></p></td><td style="text-align:right;padding:5px"><p><strong>Out Of</strong></p></td></tr>', student.feedback);

    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);
        pointsReceived = student.problems(ndxProblem).grade;
        pointsOutOf = problem.points;
        student.feedback = sprintf('%s<tr><td style="padding:5px"><p>%s</p></td><td style="text-align:right;padding:5px"><p>%.2f</p></td><td style="text-align:right;padding:5px"><p>%.2f</p></td></tr>', student.feedback, problem.name, pointsReceived, pointsOutOf);
    end

    % add total grade
    student.feedback = sprintf('%s<tr><td style="padding:5px"><p><strong>Total Grade</strong></p></td><td style="text-align:right;padding:5px"><p>%.2f</p></td><td style="text-align:right;padding:5px"><p>%.2f</p></td></tr>', student.feedback, student.grade, rubric.points);

    % close grade table
    student.feedback = sprintf('%s</table>', student.feedback);
        
    for ndxProblem = 1:length(rubric.problems)
        problem = rubric.problems(ndxProblem);

        % concatenate problem header
        student.feedback = sprintf('%s<hr/><h2>%s.m</h2>', student.feedback, problem.name);

        student = getProblemFeedback(problem, student, ndxProblem);
    end

    % terminate student feedback
    student.feedback = sprintf('%s</div>', student.feedback);

    % get feedback folder path
    settings = getSettings();
    feedbackFilePath = fullfile(student.folderPaths.feedbackAttachments, settings.fileNames.FEEDBACK);

    % write feedback file
    fh = fopen(feedbackFilePath, 'w');
    fprintf(fh, '%s', student.feedback);
    fclose(fh);
end