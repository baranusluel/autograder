%% TestResult: Run test case and record results
%
% TestResult class is responsible for running a single test case.
%
%%% Fields
%
% * path: The path to this test's directory
% * name: The name of this test
% * passed: Whether or not this test passed
% * message: Optional message for this test case
%
%%% Remarks
%
% This class represents the results of a single Unit Test - not all tests for that unit.
%
%
classdef TestResult < handle
    properties (Access=public)
        path;
        name;
        passed;
        message;
    end
    methods
        function this = TestResult(path)
        %% Constructor
        %
        % Run a given single test
        %
        % this = TestResult(P) will use the path in P to create a TestResult. The path should lead to
        % that folder's specific unit test (the single test).
        %
        %%% Remarks
        %
        % This constructor creates a single test case from the given path - it does not generate a test case
        %
        %%% Exceptions
        %
        % This function is guaranteed to never throw an exception
            % create temporary directory
            workDir = tempname;
            mkdir(workDir);
            origPath = cd(path);
            % copy over everything in the PATH directory
            copyfile([pwd filesep '*'], workDir);
            % copy over any FILES in parent
            files = dir('..');
            files([files.isdir]) = [];
            for f = 1:numel(files)
                copyfile([files(f).folder filesep files(f).name], workDir);
            end

            this.path = path;
            [~, this.name, ~] = fileparts(path);
            cd(workDir);
            % we know test.m will exist
            [this.passed, this.message] = test();
            cd(origPath);
            % completely delete folder
            [~] = rmdir(workDir, 's');
        end
    end
    methods (Access=public)
        %% generateHtml: Create HTML feedback for this test
        %
        % Create HTML feedback
        %
        % H = generateHtml(this) will use this to create the HTML in H. It will be a row with the results.
        % this HTML is _not_ suitable for presentation - it is the "bare-bones"
        %
        %%% Remarks
        %
        % This is used to generate the overall test results. It is unlikely to be used outside of this role
        %
        %%% Exceptions
        %
        % This function is guaranteed to never throw an exception
        function html = generateHtml(this)

        end
    end
end