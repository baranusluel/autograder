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
%%% Remarks
% 
% *TBD*
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
        % contain the appropriate information for the Problem
        %
        %%% Remarks
        %
        % *TBD*
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
        % 1) Valid and Complete JSON
        %
        % 2) JSON missing information
        %
        % 
        function this = Problem(JSON)
            
        end
    end
end

