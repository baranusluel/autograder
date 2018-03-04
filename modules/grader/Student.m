%% Student: Class Representing a Student
%
% Represents a single student in the grader.
% 
% Holds student's relevant information (identification, submissions,
% feedback, etc.) as fields.
%
% Has methods to grade student's submissions and generate Feedback.
%
%%% Fields
%
% - name: Full name of the student
%
% - id: The ID (GT username) of the student (e.g. busluel3)
%
% - path: The fully qualified path for this student's directory
%
% - submissions: A string array of file names that represent all names
% of submitted files.
%
% - feedbacks: A cell array of Feedback arrays. Each cell is a Feedback
% array representing all test cases for a specific problem.
%
% - isGraded: A logical that indicates whether a student has been graded
%
%%% Methods
%
% - gradeProblem
%
% - generateFeedback
%
%%% Remarks
%
% **TBD**
%

%% gradeProblem

%% generateFeedback: Generate HTML feedback for student
%
% generateFeedback is used to create an HTML file containing the homework
% feedback for a student.
%
% HTML = generateFeedback() will return a char vector HTML containing the
% markup representing the student's feedback.
%
%%% Remarks
%
% Calls the generateFeedback method of the Feedback class, for each
% Feedback in Student's feedbacks cell array, to get the HTML feedback for
% individual TestCase's. Puts together a complete, personalized HTML
% webpage for the student using this data and the name and id fields.
%
%%% Exceptions
%
% An AUTOGRADER:STUDENT:GENERATEFEEDBACK:MISSINGFEEDBACK exception will be
% thrown if the feedbacks field of the Student is empty (i.e. if
% gradeProblem wasn't invoked first).
%
%%% Unit Tests
%
% When invoked in a Student class containing a valid (non-empty)
% feedbacks field, generateFeedback will generate an HTML page with:
% - A header, containing the name of the homework as the title, and the
% student's name and ID.
% - A table with the student's points on each problem and total score.
% - A section for each individual problem, where every test case and the
% result (including points received, reason for losing points, visual
% comparison of file outputs) is listed.