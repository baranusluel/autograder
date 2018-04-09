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