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
        % an AUTOGRADER:Problem:ctor:invalidInfo exception will be thrown if
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
        %    AUTOGRADER:Problem:ctor:invalidInfo
        % 
        % Given that the input is a valid parsed JSON that is missing
        % information:
        %    J = '...' % Valid parsed JSON with missing information
        %    P = Problem(J)
        % 
        %    Constructor threw exception
        %    AUTOGRADER:Problem:ctor:invalidInfo
        % 
        function this = Problem(info)
            if nargin == 0
                return;
            end
            try
                this.name = info.name;
                this.banned = info.banned;
                this.isRecursive = info.isRecursive;
                % Go through supporting files and get full paths
                for j = 1:length(info.supportingFiles)
                    info.supportingFiles{i} = [fileparts(fileparts(pwd)) filesep 'SupportingFiles' filesep info.supportingFiles{i}];
                end

                for i = length(info.testCases):-1:1
                    tInfo = info.TestCases(i);
                    tInfo.banned = this.banned; 
                    tInfo.supportingFiles = info.supportingFiles;
                    this.testCases(i) = TestCase(tInfo, [pwd filesep() 'Solutions']);
                end
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    throw(MException('AUTOGRADER:Problem:ctor:invalidInfo', ...
                        'Problem with INFO struct fields'));
                end
            end
        end
    end
end

