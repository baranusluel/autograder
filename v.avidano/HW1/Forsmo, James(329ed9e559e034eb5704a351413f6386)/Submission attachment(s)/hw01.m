%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name         : James Forsmo
% T-square ID  : jforsmo3
% GT Email     : jforsmo3@gatech.edu
% Homework     : HW01 Resubmission
% Course       : CS1371
% Section      : DO4
% Collaboration: "I worked on the homework assignment alone, using
%                  only course materials."
%
% Files to submit:
%	ABCs_functions.m
%	ABCs_homeworkOverview.m
%	candy.m
%	cartDist.m
%	f.m
%	freefall.m
%	hw01.m
%
% Instructions:
%   1) Follow the directions for each problem very carefully or you will
%   lose points.
%   2) Make sure you name functions exactly as described in the problems or
%   you will not receive credit.
%   3) Read the announcements! Any clarifications and/or updates will be
%   announced on T-Square. Check the T-Square announcements at least once
%   a day.
%   4) You should not use any of the following functions in any file that 
%   you submit to T-Square:
%       a) clear
%       b) clc
%       c) solve
%       d) input
%       e) disp
%       f) close all
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
%% PART 1.  ABC Problems
%--------------------------------------------------------------------------
%
% Part of this homework are m-files called "ABCs_homeworkOverview.m" and "ABCs_functions.m".
% Open these files in MATLAB and complete them
% according to the directions contained within. You can test your answers with
% the test file listed below.
%
% Files to Complete: 
%	ABCs_homeworkOverview.m
%	ABCs_functions.m
%
% ABCs File Testing:
%	ABCs_hw01_pretest.p
%
%==========================================================================
%% PART 2. Drill Problems
%--------------------------------------------------------------------------
%
% Included with this homework is a file entitled "HW01_DrillProblems.pdf",
% containing instructions for 4 drill problems that cover the
% following topic:
%
%	Basics
%
% Follow the directions carefully to write code to complete the drill
% problems as described. Make sure file names as well as function headers
% are written exactly as described in the problem text. If your function
% headers are not written as specified, you will recieve an automatic
% zero for that problem.
%
%==========================================================================
%% PART 3. Testing Your Code
%--------------------------------------------------------------------------
%
% You may use the following test cases for each problem to test your code.
% The function call with the test-inputs is shown in the first line of each
% test case, and the correct outputs are displayed in subsequent lines.
%
%% Function Name: f
%
% Test Cases:
% [out1] = f(2, 3, 4)
% 	out1 => 0
% 
% [out2] = f(0, 3, 1292)
% 	out2 => 1
%
%--------------------------------------------------------------------------------
%% Function Name: cartDist
%
% Test Cases:
% [dist1] = cartDist(4, 5, 7, 9)
% 	dist1 => 5
% 
% [dist2] = cartDist(4, 3, -7, -10)
% 	dist2 => 17.03
% 
% [dist3] = cartDist(0, 0, 0, 0)
% 	dist3 => 0
%
%--------------------------------------------------------------------------------
%% Function Name: freefall
%
% Test Cases:
% [pos1, veloc1] = freefall(4)
% 	pos1 => 78.456
% 	veloc1 => 39.228
% 
% [pos2, veloc2] = freefall(3.2)
% 	pos2 => 50.212
% 	veloc2 => 31.382
% 
% [pos3, veloc3] = freefall(18.98)
% 	pos3 => 1766.439
% 	veloc3 => 186.137
%
%--------------------------------------------------------------------------------
%% Function Name: candy
%
% Test Cases:
% [perKid1, wasted1] = candy(300, 12)
% 	perKid1 => 25
% 	wasted1 => 0
% 
% [perKid2, wasted2] = candy(34, 13)
% 	perKid2 => 2
% 	wasted2 => 8
% 
% [perKid3, wasted3] = candy(100, 10)
% 	perKid3 => 10
% 	wasted3 => 0
%
