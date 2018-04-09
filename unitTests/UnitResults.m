%% UnitResults: Run and record all tests for this Unit
%
% UnitResults is responsible for running all unit tests for the specified unit
%
%%% Fields
%
% * path: The path to this unit's directory
% * name: The name of this unit
% * passed: Whether or not all the unit tests passed
%
%%% Remarks
%
% This class runs all tests for the Unit
%

classdef UnitResults < handle
    properties (Access=public)
        path;
        name;
        passed;
    end
    properties (Access=private)
        testResults;
    end
    methods
        function this = UnitResults(path)
            this.path = path;
            [~, this.name, ~] = fileparts(path);
            % find all unit tests (just all directories) - then, create them
            origPath = cd(path);
            units = dir();
            units(~[units.isdir]) = [];
            units(strncmp({units.name}, '.', 1)) = [];
            for i = numel(units):-1:1
                this.testResults(i) = TestResult(fullfile(units.folder, units.name));
            end
        end
        function passed = get.passed(this)
            passed = all([this.testResults.passed]);
        end
    end
    methods (Access=public)
        function html = generateHtml(this)

        end
    end
end