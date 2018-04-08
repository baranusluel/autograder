%% Problem: Class representing a Problem
% 
% This represents a single problem set 
% 
% Includes the name of the file, the test cases, and any banned functions
% as fields
%
%%% Fields
%
% * name: the name of the problem (function name without a .m).
% 
% * testCases: TestCase[] representing each test case for the problem.
%
% * banned: a cell array of names of banned functions for this problem.
%
% * isRecursive: logical indicating whether the problem is recursive or not
%
%%% Methods
% 
% * Problem
% 
classdef Problem < handle
    properties (Access = public)
        name;
        testCases;
        banned;
        isRecursive;
    end
    methods
        %% Constructor: 
        %
        % The constructor creates a new Problem from a structure representing 
		% a parsed JSON.
        %
        % P = Problem(J) will return a Problem with all the fields
        % containing the appropriate information for the Problem
        %
        %%% Remarks
        %
        % The Problem constructor will _not_ catch any errors thrown by
        % TestCase; these are fatal errors that generally mean something 
        % serious is wrong with the solution structure.
        %
        %%% Exceptions
        %
        % an AUTOGRADER:PROBLEM:INVALIDINFO exception will be thrown if
        % the structure is incorrectly formatted or missing information
        %
        % Does not catch exceptions thrown by testCase
        %
        %%% Unit Tests
        %
        % Given that the input is a complete and valid parsed JSON:
        %    J = '...' % Valid parsed JSON
        %    P = Problem(J)
        %
        %    P -> complete Problem with a defined name and a cell
        %    array of the names of banned functions
        %
        % Given that the input is an invalid parsed JSON:
        %    J = '...' % Invalid parsed JSON
        %    P = Problem(J)
        %
        %    Constructor threw exception
        %    AUTOGRADER:PROBLEM:INVALIDINFO
        % 
        % Given that the input is a valid parsed JSON that is missing
        % information:
        %    J = '...' % Valid parsed JSON with missing information
        %    P = Problem(J)
        % 
        %    Constructor threw exception
        %    AUTOGRADER:PROBLEM:INVALIDINFO
        % 
        function this = Problem(info)
            try
                this.name = info.name;
                this.banned = info.banned;
                this.isRecursive = info.isRecursive;
                for i = length(info.testCases):-1:1
                    tInfo = info.TestCases(i);
                    tInfo.banned = this.banned; 
                    this.testCases(i) = TestCase(tInfo, 'path/to/solution/file');
                end
            catch 
                throw(MException('AUTOGRADER:PROBLEM:PROBLEM:INVALIDINFO', ...
                    'Problem with INFO struct fields'));
            end
        end
    end
end

