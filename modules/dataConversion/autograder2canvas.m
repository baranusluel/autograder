%% autograder2Canvas: Generate Canvas files from autograder
% 
% Create the gradebook csv file used by canvas to import grades.
%
% autograder2Canvas(S, C, H) takes the graded Student Array in S and writes
% it to the CSV given by the path in C in the assignment name specified by
% H.
%
% This function will take in a graded student array (S), the name of the
% gradebook from the canvas website(C), and the name of the homework that 
% it is grading (H). H should be selected before the autograder runs and as
% such should always be valid.
%
% This function will edit the gradebook such that it has the new scores
% from the student array.
%
%%% Remarks
%
% If autograder2canvas is given an ungraded student in an array, it will
% simply pass over the student and not put a grade in the gradebook.
%
%
%%% Exceptions
%
% AUTOGRADER:AUTOGRADER2CANVAS:MISSINGGRADEBOOK exception will be thrown if
% the function is run without a valid gradebook file name.
%
% AUTOGRADER:AUTOGRADER2CANVAS:MISSINGSTUDENTS exception will be thrown if
% the function is run without a valid student array
% 
% AUTOGRADER:AUTOGRADER2CANVAS:INVALIDGRADEBOOK exception will be thrown if
% the function is run with an invalid gradebook file name.
%
%%% Unit Tests
%
% 1)
% Inputs:
%   Graded StudentArray
%   Valid Gradebook Name
%   Valid Homework Name
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% File Outputs:
%   An Updated Gradebook
%
% 2)
% Inputs:
%   Graded StudentArray
%   Invalid Gradebook Name
%   Valid Homework Name
%
% Runtime:
%   INVALIDGRADEBOOK exception
%
% Outputs:
%   None
% File Outputs:
%   None
%
% 3)
% Inputs:
%   Ungraded StudentArray
%   Valid Gradebook Name
%   Valid Homework Name
%
% Runtime:
%   None
%
% Outputs:
%   None
% File Outputs:
%   None
%
% 4)
% Inputs:
%   Ungraded StudentArray
%   Invalid Gradebook Name
%   Valid Homework Name
%
% Runtime:
%   INVALIDGRADEBOOK exception
%
% Outputs:
%   None
% File Outputs:
%   None