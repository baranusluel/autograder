%% autograder2canvas: Generate Canvas files from autograder
% 
% Create the gradebook csv file used by canvas to import grades.
% 
% autograder2canvas(studentArray, canvasGradebookFileName, *optional* homeworkName)
%
% This function will take in a graded Student Array, the name of the
% gradebook from the canvas website, and the name of the homework that it
% is grading. The homework Name should be selected before the autograder
% runs and as such should always be valid.
%
% This function will edit the gradebook such that it has the new scores
% from the student array.
%
%%% Remarks
%
% If autograder2canvas is given an ungraded student in an array, it will
% simply pass over the student and not put a grade in the gradebook.
%
% If autograder2canvas should never be given an invalid homeworkName
% because it should come from the original inputs to the function.
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