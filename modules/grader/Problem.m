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
%%% Methods
% 
% * Problem
% 
classdef Problem < handle
    properties (Access = public)
        name;
        testCases;
        banned;
    end
    methods
        %% Constructor: 
        %
        % The constructor creates a new Problem from a JSON.
        %
        % P = Problem(J) will return a Problem with all the fields
        % containing the appropriate information for the Problem
        %
        %%% Remarks
        %
        % The Problem constructor will _not_ catch any errors thrown by
        % TestCase; these are fatal errors that generally mean something 
        % serious is wrong with the solution JSON file.
        %
        %%% Exceptions
        %
        % an AUTOGRADER:PROBLEM:INVALIDJSON exception will be thrown if
        % the JSON file is incorrectly formatted or missing information
        %
        % Does not catch exceptions thrown by testCase
        %
        %%% Unit Tests
        %
        % Given that the input is a complete and valid JSON:
        %    J = '...' % Valid JSON
        %    P = Problem(J)
        %
        %    P -> complete Problem with a defined name and a cell
        %    array of the names of banned functions
        %
        % Given that the input is an invalid JSON:
        %    J = '...' % Invalid JSON
        %    P = Problem(J)
        %
        %    Constructor threw exception
        %    AUTOGRADER:PROBLEM:INVALIDJSON
        % 
        % Given that the input is a valid JSON that is missing
        % information:
        %    J = '...' % Valid JSON with missing information
        %    P = Problem(J)
        % 
        %    Constructor threw exception
        %    AUTOGRADER:PROBLEM:INVALIDJSON
        % 
        function this = Problem(JSON)
            
        end
    end
end

