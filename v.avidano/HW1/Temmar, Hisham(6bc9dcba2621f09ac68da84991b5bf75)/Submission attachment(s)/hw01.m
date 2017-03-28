%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name         : Hisham Temmar
% T-square ID  : htemmar3
% GT Email     : htemmar3@gatech.edu
% Homework     : 1
% Course       : CS1371
% Section      : C03
% Collaboration: I worked on the homework assignment alone, using only course materials.
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
% [out1] = f(0, 3, 1292)
% 	out1 => 1
%
%--------------------------------------------------------------------------------
%% Function Name: cartDist
%
% Test Cases:
% [out1] = cartDist(4, 5, 7, 9)
% 	out1 => 5
% 
% [out1] = cartDist(4, 3, -7, -10)
% 	out1 => 17.03
% 
% [out1] = cartDist(0, 0, 0, 0)
% 	out1 => 0
%
%--------------------------------------------------------------------------------
%% Function Name: freefall
%
% Test Cases:
% [out1, out2] = freefall(4)
% 	out1 => 78.456
% 	out2 => 39.228
% 
% [out1, out2] = freefall(3.2)
% 	out1 => 50.212
% 	out2 => 31.382
% 
% [out1, out2] = freefall(18.98)
% 	out1 => 1766.439
% 	out2 => 186.137
%
%--------------------------------------------------------------------------------
%% Function Name: candy
%
% Test Cases:
% [out1, out2] = candy(300, 12)
% 	out1 => 25
% 	out2 => 0
% 
% [out1, out2] = candy(34, 13)
% 	out1 => 2
% 	out2 => 8
% 
% [out1, out2] = candy(100, 10)
% 	out1 =>     10
% 	out2 =>      0
%
