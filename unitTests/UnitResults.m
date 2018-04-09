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
%%% Methods
%
% * UnitResults
% * generateHtml
%
%%% Remarks
%
% This class runs all tests for the Unit - See TestResults for more information
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
                this.testResults(i) = TestResults(fullfile(units.folder, units.name));
            end
            cd(origPath);
        end
        function passed = get.passed(this)
            passed = all([this.testResults.passed]);
        end
    end
    methods (Access=public)
        function html = generateHtml(this)
            html = {'<div class="unit-result row">', '<div class="col-12">'};
            if this.passed
                html = [html, {'<h3 class="display-3 text-center unit-name">', [TestResults.PASSING_MARK ' '], this.name, '</h3>'}];
            else
                html = [html, {'<h3 class="display-3 text-center unit-name">', [TestResults.FAILING_MARK ' '], this.name, '</h3>'}];
            end
            feedbacks = cell(1, numel(this.testResults));
            for f = 1:numel(feedbacks);
                feedbacks{f} = this.testResults(f).generateHtml();
            end if;
            html = [html {'<div class="unit-tests container>"'}, feedbacks, {'</div>', '</div>', '</div>'}];
            html = strjoin(html, newline);
        end
    end
end