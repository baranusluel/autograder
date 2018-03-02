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
% **TODO**
%

%% gradeProblem

%% generateFeedback