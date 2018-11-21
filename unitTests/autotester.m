%% autotester: Run all unit tests and return feedback
%
% autotester will run all Unit Tests for the autograder. Then, it will (optionally) show feedback.
%
% [S, H] = autotester() will run all Unit Tests. If all of them pass, S is true; otherwise, S is
% false. H will be the base HTML feedback for all the unit tests.
%
% [S, H] = autotester(O) will use the options in structure O to run unit tests. See the Remarks
% section for more details
%
% [S, H] = autotester(P1, V1, ...) will use the options specified by parameters P1, P2, ... and
% values V1, V2, ... to run unit tests. See the Remarks section for more details
%
%%% Remarks
%
% autotester can take in a few parameters that augment it's functionality. These parameters, and
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
% * css: A character vector of a custom CSS class to use for the html. If empty, default css is applied. Default: Empty
%
%%% Exceptions
%
% This code will never throw exceptions
%

function [status, html] = autotester(varargin)
    status = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    outs = parseInputs(varargin);
    evalc('gcp;');
    % path is going to be this file's directory
    origPath = cd(fileparts(mfilename('fullpath')));
    userPath = path();
    
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
    mods(numel(modules)) = ModuleResults();
    for m = 1:numel(modules)
        mods(m) = ModuleResults(fullfile(modules(m).folder, modules(m).name));
    end

    status = all([mods.passed]);

    navs = cell(1, numel(mods));
    feedbacks = cell(1, numel(mods));
    checks = cell(1, numel(mods));
    active = ' active';
    numCols = num2str(floor(12/numel(mods)));
    for f = 1:numel(feedbacks)
        feedbacks{f} = strjoin({['<div id="' mods(f).name '" class="tab-pane' active '">'], mods(f).generateHtml(), '</div>'}, newline);
        navs{f} = strjoin({'<li class="nav-item">', ['<a class="nav-link' active '" data-toggle="pill" href="#' ...
            mods(f).name '">' camel2normal(mods(f).name) '</a>'], '</li>'}, newline);
        if mods(f).passed
            mark = TestResults.PASSING_MARK;
        else
            mark = TestResults.FAILING_MARK;
        end
        checks{f} = strjoin({['<div class="col-md-' numCols ' col-12 text-center module-status">'], mark, camel2normal(mods(f).name), '</div>'}, newline);
        active = '';
    end
    navs = [{'<div class="row text-center">', '<div class="col-12 d-none d-sm-block text-center">', ...
        '<ul class="nav nav-pills nav-fill" role = "tablist">'} navs {'</ul>', '</div>', '</div>'}, ...
        {'<div class="row text-center">', '<div class="col-12 d-block d-sm-none text-center">', ...
        '<ul class="nav nav-pills nav-fill flex-column" role = "tablist">'} navs {'</ul>', '</div>', '</div>'}];
    checks = ['<div class="row text-center d-flex justify-content-center">', checks, '</div>'];
    html = {'<div class="container-fluid">', '<div class="jumbotron text-center">'};
    if status
        html = [html {'<i class="display-1 text-center fas fa-check"></i>'}];
        html = [html {'<h1 class="display-4 text-center">Unit Tests Passed!</h1>'}];
    else
        html = [html {'<i class="display-1 text-center fas fa-times"></i>'}];
        html = [html {'<h1 class="display-4 text-center">Unit Tests Failed</h1>'}];
    end

    
    html = [html {'<hr />', strjoin(checks, newline), '</div>'}];
    html = [html, navs];
    html = [html {'<div class="tab-content">'}, feedbacks, {'</div>', '</div>'}];

    completeHtml = [generateHeader(outs.css) html '</body>', '</html>'];

    html = strjoin(html, newline);
    completeHtml = strjoin(completeHtml, newline);

    if outs.showFeedback
        file = [tempname '.html'];
        fid = fopen(file, 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
        web(['file:///' file], '-browser');
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
    set(0, 'DefaultFigureVisible', status);
end

function outs = parseInputs(ins)
    parser = inputParser();
    parser.addParameter('showFeedback', false, @islogical);
    parser.addParameter('output', '', @ischar);
    parser.addParameter('modules', {}, @iscell);
    parser.addParameter('completeFeedback', false, @islogical);
    parser.addParameter('css', '', @(p)(isempty(p) || isfile(p)));
    parser.CaseSensitive = false;
    parser.FunctionName = 'unitRunner';
    parser.KeepUnmatched = false;
    parser.PartialMatching = true;
    parser.StructExpand = true;
    parser.parse(ins{:});
    outs = parser.Results;
end

function header = generateHeader(path)
    header = {'<!DOCTYPE html>', '<html lang="en">', '<head>', ...
        '<meta charset="utf-8">', ...
        '<title>Test Results</title>', ...
        '<meta name="viewport" content="width=device-width, initial-scale=1">', ...
        '<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400&amp;subset=latin-ext" rel="stylesheet">', ...
        '<link rel="shortcut icon" type="image/x-icon" href="resources/favicon.ico" />', ...
        '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css">', ...
        '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
        '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"></script>', ...
        '<script defer src="https://use.fontawesome.com/releases/v5.0.9/js/all.js"></script>', ...
        generateCSS(path), ...
        '</head>', ...
        '<body>'};
end

function style = generateCSS(path)
    if isempty(path)
        style = {'<style>', ...
        '.fa-check {', ...
        '    color: forestgreen;', ...
        '}', ...
        '.fa-times {', ...
        '    color: darkred;', ...
        '}', ...
        '</style>'};
    else
        fid = fopen(path, 'rt');
        lines = char(fread(fid)');
        fclose(fid);
        style = {'<style>', lines, '</style>'};
    end
    style = strjoin(style, newline);
end

function newStr = camel2normal(str)
    % for each capital letter, replace with ' ' + lowercase
    newStr = char(zeros(1, length(str) + sum(str >= 'A' & str <= 'Z')));
    oldInd = 1;
    newInd = 1;
    while oldInd <= numel(str)
        if str(oldInd) >= 'a' && str(oldInd) <= 'z'
            newStr(newInd) = str(oldInd);
        else
            newStr(newInd) = ' ';
            newInd = newInd + 1;
            newStr(newInd) = str(oldInd);
        end
        newInd = newInd + 1;
        oldInd = oldInd + 1;
    end
    newStr(1) = upper(newStr(1));
end