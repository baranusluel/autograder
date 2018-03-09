%% canvas2autograder Converts canvas files to autograder structure
%
% create student array from canvas downloads
%
% students = canvas2autograder(canvasZipFile)
%
% This function will take in the zip file downloaded from canvas as well as
% the gradebook downloaded from canvas.
%
% This function will return a student array to be graded
%
%%% Remarks
%
% This function will create a series of folders within the working
% directory of the autograder to ensure that there is no confusion between
% different student's submitted files as well as create runable files from
% canvas downloaded student code.
%
%%% Exceptions
%
% AUTOGRADER:CANVAS2AUTOGRADER:INVALIDFILE if the canvasZipFile either does
% not contain students or is not in canvas format.
%
%%% Unit Tests
%
% 1)
% Inputs:
%   Valid canvasZipFile
%
% Runtime:
%   None
%
% Outputs:
%   Valid ungraded Student vector
%
% 2)
% Inputs:
%   Invalid canvasZipFile
%
% Runtime:
%   INVALIDFILE exception
%
% Outputs:
%   None
