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
            % Need to account for noargs constructor call - otherwise
            % error when preallocating a vector of UnitResults
            if nargin ~= 1
                return
            end
            
            this.path = path;
            [~, this.name, ~] = fileparts(path);
            % find all unit tests (just all directories) - then, create them
            origPath = cd(path);
            units = dir();
            units(~[units.isdir]) = [];
            units(strncmp({units.name}, '.', 1)) = [];
            for i = numel(units):-1:1
                testResults(i) = TestResults(fullfile(units(i).folder, units(i).name));
            end
            this.testResults = testResults;
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
                html = [html, {'<h3 class="display-3 unit-name">', [TestResults.PASSING_MARK ' '], this.name, '</h3>'}];
            else
                html = [html, {'<h3 class="display-3 unit-name">', [TestResults.FAILING_MARK ' '], this.name, '</h3>'}];
            end
            methods = unique({this.testResults.method});
            methods(strcmp(methods, '')) = [];
            if ~isempty(methods)
                % for each method, print accordingly
                methodFeedback = cell(1, numel(methods));
                for m = 1:numel(methods)
                    feedbackHeader = {'<div class="class-method">', '<h4 class="method-name display-4">', ...
                        methods{m}, '</h4>'};
                    res = this.testResults(strcmp(methods{m}, {this.testResults.method}));
                    feedbacks = cell(1, numel(res));
                    % for all test methods with that name
                    for t = 1:numel(res)
                        feedbacks{t} = res(t).generateHtml();
                        feedbacks{t} = strrep(feedbacks{t}, '<h4', '<h5');
                        feedbacks{t} = strrep(feedbacks{t}, '</h4>', '</h5>');
                    end
                    methodFeedback{m} = [feedbackHeader, feedbacks, {'</div>'}];
                end
                feedback = [methodFeedback{:}];
            else
                feedbacks = cell(1, numel(this.testResults));
                for f = 1:numel(feedbacks)
                    feedbacks{f} = this.testResults(f).generateHtml();
                end
                feedback = feedbacks;
            end
            html = [html {'<div class="unit-tests container">'}, feedback, {'</div>', '</div>', '</div>'}];
            html = strjoin(html, newline);
        end
    end
end