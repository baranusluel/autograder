%% grader_test: Test the Grader module
%
% grader_test will run all the tests contained for this module
%
% [R, H] = grader_test(O, ...) will run all the unit tests in this module,
% and will return the results as a structure array. See the documentation
% for more information about the options and outputs for this function.
%
%%% Remarks
%
% This tests all tests for the |grader| module. If you'd like to run a
% specific test, run that function specifically
%
%%% Exceptions
%
% This function is guaranteed to never throw an exception.
%
% See Also: Main

function [results, html] = grader_test(varargin)
    outs = parseTestInputs(varargin{:});
    oldFolder = cd(fileparts(mfilename('fullpath')));
    % get all tests in folder
    tests = dir('*_test.m');
    tests(strcmp({tests.name}, 'grader_test.m')) = [];
    % for each of them, capture outputs.
    
    % set up html
    feedbacks = cell(1, numel(tests));
    % set up results. All results have same look, so we can put in
    % structure vector
    results = cell(1, numel(tests));
    for t = 1:numel(tests)
        test = str2func(tests(t).name(1:end-2));
        % run the test
        [results{t}, feedbacks{t}] = test();
    end
    
    % collapse results
    results = [results{:}];
    for r = 1:numel(results)
        results(r).module = 'grader';
    end
    
    % build html
    % for each test, build test html
    % if all of results are passed, say so
    if ~all([results.status])
        header = {'<div class="module-results">', ...
            '<h2 class="module-header">', ...
            '<span class="fas fa-times></span> Grader Module', ...
            '</h2>'};
    else
        header = {'<div class="module-results">', ...
            '<h2 class="module-header">', ...
            '<span class="fas fa-check></span> Grader Module', ...
            '</h2>'};
    end
    
    % for each function (i.e., each complete Unit Test), print that
    % function's complete HTML.
    
    % prealloc (each function has <div class="unit-results">, <stuff>,
    % </div>)
    html = cell(1, 3 * numel(feedbacks));
    for t = 0:numel(feedbacks) - 1
        html{(t*3) + 1} = '<div class="unit-results">';
        html{(t*3) + 2} = feedbacks{t+1};
        html{(t*3) + 3} = '</div>';
    end
    html = [header html {'</div>'}];
    
    completeHtml = [generateHeader() {'<div class="container-fluid">', ...
        '<div class="row">', '<div class="col-12">'}, html, ...
        {'</div>', '</div>', '</div>', '</body>', '</html>'}];
    % if outs.feedbackPath ~= '', engage
    if ~isempty(outs.feedbackPath)
        % write html
        fid = fopen([outs.feedbackPath filesep 'grader_results.html'], 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
    end
    % if out.showFeedback, write temp feedback file and show
    if outs.showFeedback
        fName = [tempname '.html'];
        fid = fopen(fName, 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
        web(['file:///', fName]);
    end
    
    
    cd(oldFolder);
    
end