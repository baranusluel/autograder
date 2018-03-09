%% generateSolutions: generate the solution values for comparison 
%   
% This will generate the solution values, given a path to the 
% solution ZIP archive. These solutions are held in a `Problem` array.
%
% PROBLEMS = generateSolutions(PATH) will return a Problem Array containing
% the problems for the current homework specified by PATH, which is a
% string representation of the path to the solution ZIP archive
% 
%%% Remarks
% 
% *TBD*
% 
%%% Exceptions
% 
% generateSolutions throws exception ?? if the input path is invalid
% generateSolutions throws exception ?? if a necessary file is missing in
% the given directory
% 
% 
%%% Unit Tests
% 
% 1) Valid Case --> Returns Problem Array with all field correctly filled
% for each problem
%
% 2) If the path is invalid --> throws an exception
% 
% 3) If the solution file errors --> Exception thrown in TestCase constructor
% not caught in generateSolutions
% 
% 4) If there is a missing file (solution file, supporting file, JSON,etc)
% --> Throws an exception


