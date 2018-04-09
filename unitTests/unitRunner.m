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
% * modules: A cell array of character vectors. If given and non-empty, only modules that match the name in
% given in the cell array are tested. If empty or not given, all modules are assumed. Default: empty cell array
%
%%% Exceptions
%
% This code will never throw exceptions
%

function [status, html] = unitRunner(varargin)

end

function outs = parseInputs(varargin)
    parser = inputParser();
    parser.addParameter('showFeedback', false, @islogical);
    parser.addParameter('output', '', @ischar);
    parser.addParameter('modules', {}, @iscell);
    parser.CaseSensitive = false;
    parser.FunctionName = 'unitRunner';
    parser.KeepUnmatched = false;
    parser.PartialMatching = true;
    parser.StructExpand = true;
    parser.parse(varargin{:});
    outs = parser.Results;
end