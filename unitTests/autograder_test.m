%% autograder_test: Tests all units of the Autograder
%
% This function tests all individual units (functions & classes), and will
% optionally show feedback.
%
% [R, H, P] = autograder_test(O, ...) Will use the options given in O (either
% a structure, or a set of name-value pairs) to generate a complete test
% suite of unit tests. The results of these tests are found in R as a
% structure array, while the HTML feedback can be found in H. If you'd like
% to see the complete feedback, use the options. For more information,
% check the documentation. P is only true if everything passed
%
%%% Remarks
%
% Unlike all other tests, this one returns a logical if all tests passed.
% This is different, and is used by |build| to check if everything passes
% before building
%
%%% Exceptions
%
% This function is guaranteed to never throw an exception
%
function [results, html, isPassing] = autograder_test(varargin)
    outs = parseTestInputs(varargin{:});
    
    % set up cell arrays of cell arrays
    oldPath = cd(fileparts(mfilename('fullpath')));
    % get all module names
    modules = dir;
    modules(strncmp({modules.name}, '.', 1)) = [];
    modules(~[modules.isdir]) = [];
    modules(strcmp({modules.name}, 'resources')) = [];
    % only have modules left
    results = cell(1, numel(modules));
    feedbacks = cell(1, numel(modules));
    
    % for each module, cd into it, run it's main function, and exit
    for m = 1:numel(modules)
        orig = cd(modules(m).name);
        func = str2func([modules(m).name '_test']);
        [results{m}, feedbacks{m}] = func();
        cd(orig);
    end
    
    % combine HTML
    if ~all([results.status])
        isPassing = true;
        header = {'<div class="module-results">', ...
            '<h1 class="module-header">', ...
            '<span class="fas fa-times></span> Autograder Test Suite', ...
            '</h1>'};
    else
        isPassing = false;
        header = {'<div class="module-results">', ...
            '<h1 class="module-header">', ...
            '<span class="fas fa-check></span> Autograder Test Suite', ...
            '</h1>'};
    end
    html = cell(1, 3 * numel(feedbacks));
    for t = 0:numel(feedbacks) - 1
        html{(t*3) + 1} = '<div class="module-results">';
        html{(t*3) + 2} = feedbacks{t+1};
        html{(t*3) + 3} = '</div>';
    end
    html = strjoin([header html {'</div>'}], newline);
    
    completeHtml = strjoin([generateHeader() {'<div class="container-fluid">', ...
        '<div class="row">', '<div class="col-12">'}, html, ...
        {'</div>', '</div>', '</div>', '</body>', '</html>'}], newline);
    results = [results{:}];
    
    if ~isempty(outs.feedbackPath)
        % write html
        fid = fopen([outs.feedbackPath filesep 'autograder_results.html'], 'wt');
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
    cd(oldPath);
end