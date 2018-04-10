%% unitRunner: Run all unit tests and return feedback
%
% unitRunner will run all Unit Tests for the autograder. Then, it will (optionally) show feedback.
%
% [S, H] = unitRunner() will run all Unit Tests. If all of them pass, S is true; otherwise, S is
% false. H will be the base HTML feedback for all the unit tests.
%
% [S, H] = unitRunner(O) will use the options in structure O to run unit tests. See the Remarks
% section for more details
%
% [S, H] = unitRunner(P1, V1, ...) will use the options specified by parameters P1, P2, ... and
% values V1, V2, ... to run unit tests. See the Remarks section for more details
%
%%% Remarks
%
% unitRunner can take in a few parameters that augment it's functionality. These parameters, and
% their effects, are listed below:
%
% * showFeedback: A logical. If true, the built-in web browser will show you the HTML feedback for
% the unit tests that were run. Default: true
%
% * output: A character vector. If given and a folder path, the *full* html output (including boilerplate)
% will be written to that path, in a file called results.html. If a file path is given, that name is used
% instead. Default: Empty character vector
%
% * completeFeedback: A logical. If true, _complete_ feedback is returned (including header, etc.). Default: false
%
% * modules: A cell array of character vectors. If given and non-empty, only modules that match the name in
% given in the cell array are tested. If empty or not given, all modules are assumed. Default: empty cell array
%
%%% Exceptions
%
% This code will never throw exceptions
%

function [status, html] = unitRunner(varargin)
    outs = parseInputs(varargin);
    
    % path is going to be this file's directory
    origPath = fileparts(mfilename('fullpath'));
    userPath = path();
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    % get all modules:
    modules = dir();
    modules(~[modules.isdir]) = [];
    modules(strncmp({modules.name}, '.', 1)) = [];
    if isempty(outs.modules)
        outs.modules = {modules.name};
    end

    % for each module, create ModuleResults
    for m = numel(modules):-1:1
        % check it's asked for
        if ~any(strcmpi(modules(m).name, outs.modules))
            modules(m) = [];
        end
    end

    for m = numel(modules):-1:1
        mods(m) = ModuleResults(fullfile(modules(m).folder, modules(m).name));
    end

    status = all([mods.passed]);

    feedbacks = cell(1, numel(mods));
    for f = 1:numel(feedbacks)
        feedbacks{f} = mods(f).generateHtml();
    end

    html = {'<div class="container-fluid">', '<div class="jumbotron text-center">'};
    if status
        html = [html {'<i class="display-1 text-center fas fa-check"></i>'}];
        html = [html {'<h1 class="display-3 text-center">Code Passed Inspection!</h1>'}];
    else
        html = [html {'<i class="display-1 text-center fas fa-times"></i>'}];
        html = [html {'<h1 class="display-3 text-center">Code Failed Inspection</h1>'}];
    end
    html = [html {'<hr />', '<p class="lead">Read below for a list of test results</p>', '</div>'}];
    html = [html {'<div class="results">'}, feedbacks, {'</div>', '</div>'}];

    completeHtml = [generateHeader() html '</body>', '</html>'];

    html = strjoin(html, newline);
    completeHtml = strjoin(completeHtml, newline);

    if outs.showFeedback
        file = tempname;
        fid = fopen(file, 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
        web(['file:///' file]);
    end

    if ~isempty(outs.output)
        if isfolder(outs.output)
            fid = fopen([outs.outputs filesep 'results.html'], 'wt');
        else
            fid = fopen(outs.output, 'wt');
        end
        if fid ~= -1
            fwrite(fid, completeHtml);
            fclose(fid);
        end
    end
    if outs.completeFeedback
        html = completeHtml;
    end
    cd(origPath);
    path(userPath, '');
end

function outs = parseInputs(ins)
    parser = inputParser();
    parser.addParameter('showFeedback', false, @islogical);
    parser.addParameter('output', '', @ischar);
    parser.addParameter('modules', {}, @iscell);
    parser.addParameter('completeFeedback', false, @islogical);
    parser.CaseSensitive = false;
    parser.FunctionName = 'unitRunner';
    parser.KeepUnmatched = false;
    parser.PartialMatching = true;
    parser.StructExpand = true;
    parser.parse(ins{:});
    outs = parser.Results;
end

function header = generateHeader()
    header = {'<!DOCTYPE html>', '<html lang="en">', '<head>', ...
        '<meta charset="utf-8">', ...
        '<title>Test Results</title>', ...
        '<meta name="viewport" content="width=device-width, initial-scale=1">', ...
        '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
        '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
        '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
        '<script defer src="https://use.fontawesome.com/releases/v5.0.9/js/all.js"></script>', ...
        '<style>', ...
        '.fa-check {', ...
        '    color: forestgreen;', ...
        '}', ...
        '.fa-times {', ...
        '    color: darkred;', ...
        '}', ...
        '</style>', ...
        '</head>', ...
        '<body>'};
end