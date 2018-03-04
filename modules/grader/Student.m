%% Student: Class Representing a Student
%
% Represents a single student in the grader.
% 
% Holds student's relevant information (identification, submissions, 
%feedback, etc.) 
%as fields.
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

%% gradeProblem: Grades the given problem and records the results
%   
% gradeProblem is used to evaluate the student code for a given problem and
% records the results in the feedbacks field
%
% gradeProblem(PROBLEM) will take in a valid PROBLEM class, evaluates the 
% student code, creates a Feedback instance for each TestCase, which in turn 
% gets added to the feedbacks field.
%
%%% Remarks
%
% The feedback field should always be populated, even if submissions field is
% empty
%
% If Matlab throws an exception, this function will catch the exception and
% output it to the reason field in Feedback. If the reason field already
% has content in it, the exception ID will be concatenated to the data
% already found in reason.
%
%%% Exceptions
%
% TBD need to take care of infinite loops
%
%%% Unit Tests
%
% Given a student who had submitted all files:
% The student code is evaluated and a Feedback instance is created.
% The Feedback class will then be added to the feedbacks field.
%
% Given a student who had only partially submitted files:
% The student code is evaluated normally for non-empty submissions
% and Feedback instances are created. Empty submissions will
% give appropritate score and reason values in the Feedback class. 
% The Feedback classes will then be added to the feedbacks field.
%
% Given a student who had no submitted files:
% Empty submissions will give appropritate score and reason values in the 
% Feedback class.
% The Feedback classes will then be added to the feedbacks field.
%
%% generateFeedback