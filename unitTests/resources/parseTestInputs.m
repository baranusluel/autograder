%% parseTestInputs: Parse the inputs for this test
%
% A wrapper for using |inputParser|
%
% O = parseTestInputs(N, ...) will parse the inputs found in the variable
% input, returning the inputParser object as O. The function name is 
%
%%% Remarks
%
% This function serves as a central input parser for all unit tests. It
% should not be used outside of this context
%
% See Also: inputParser

function outputs = parseTestInputs(varargin)

parser = inputParser();
parser.addParameter('feedbackPath', '', @(p)(isempty(p) || isfolder(p)));
parser.addParameter('showFeedback', false, @islogical);

parser.CaseSensitive = false;
temp = dbstack;
parser.FunctionName = temp(2).name;
parser.KeepUnmatched = false;
parser.PartialMatching = true;
parser.StructExpand = true;
parser.parse(varargin{:});

outputs = parser.Results;