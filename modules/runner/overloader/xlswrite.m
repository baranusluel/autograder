%% xlswrite: output students' excel files 
%
% overload MATLAB's built-in xlswrite to produce comparable cell arrays
%
% [O, M] = xlswrite(I, T) and give a description of what this function
% will do. This can (and should) be descriptive, spanning multiple lines.
% If you hit 80 characters on a single line, just hit return, type a new
% '%' sign, and keep typing. Consecutive lines will be read as one long line
% when published.
%
%%% Remarks
%
% Remarks is where you can freely talk about anything peculiar, notable, or
% otherwise important about this function. What special conditions are there?
% Are there any environment conditions? Does it matter what kind of machine
% this is run on? What purpose does this function fix? Are there any known
% issues with this function? Is it case sensitive? How does it deal with NaN?
%
% Each separate remark should be separated by an empty line.
%
%%% Exceptions
%
% State any exceptions your code throws, and the conditions for those exceptions.
%
% functionName throws exception APPNAME:MODULENAME:FUNCTIONNAME:ERROR if condition
% is met.
%
%%% Unit Tests
%
% This is a place for you to provide tests for your function. Unit Tests
% need to be exhaustive. What does this mean? It means that it needs to
% completely enumerate this function's behavior. How does it behave if an input
% is empty? CaSe SeNsItIvItY? Invalid inputs? Basically, a test case for
% testing the normal usage, and a test case for each edge case.
%
% Test Cases always start with a TAB; this tell's the publisher to mark it as
% MATLAB code. The basic template is:
%
%   S = 'Set Up Your Inputs First';
%   T = 'It's ok to make your variable names one letter.'
%   [O, M] = functionName(S, T); % Run your function!
%
%   The output appears on a new line, and describing it looks like this:
%   O -> MATLAB code that produces output
%
%   S = ["Hello"; "WOrld"];
%   P = 'O';
%   M = strFound(S, P);
%
%   M -> [false; true];
%
%   S = 'HelloWorld';
%   P = "w";
%   M = strFound(S, P);
%
%   M -> false;
%
%   S = {'hello', [1 2 3]};
%   P = 'wassup';
%   M = strFound(S, P);
%
%   Exception Raised: TEXTS is not uniform
%
%   S = {'hello'};
%   P = {[1 2 3]};
%   M = strFound(S, P);
%
%   Exception Raised: PATTERNS is not uniform