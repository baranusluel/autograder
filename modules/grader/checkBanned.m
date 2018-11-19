%% checkBanned: Check a function file for banned function usage
%
% checkBanned will read a function file to determine if it ever uses a
% banned function.
%
% [I, F] = checkBanned(N, B, P) will use function name N, cell array of
% banned function names B, and path P to determine if the function used any
% banned functions. If it did, then I will be true, and F will contain a
% comma separated string of all the banned functions. Otherwise, I will be
% false, and F will be empty.
%
%%% Remarks
%
% checkBanned will use the mtree function to create an AST of the student's
% code. Any bugs in mtree will, therefore, propogate forward.
%
% checkBanned recursively checks the student's code, walking the call chain
% until it reaches a built-in function, or terminates. This means that if a
% built in function uses a banned function, then that won't be caught.
%
% checkBanned does static checking of the student file, which means it can
% be quite performant. However, strictly speaking, this means that
% sometimes the student can "trick" the autograder into thinking it did
% call a banned function. Specifically, suppose the coder had the
% following code:
%
%   if false
%       bannedFunction();
%   end
%
% checkBanned would still return true, because it has no way of knowing
% that the code won't actually be run.
%
% Should the student overwrite a banned function (i.e., they wrote a
% separate file called "bannedFunction.m"), checkBanned will not mark them
% as using a banned function, unless bannedFunction.m uses a banned
% function.
function [isBanned, bannedFunName] = checkBanned(name, banned, path)

    calls = getCalls([path filesep name]);
    % calls is complete set of calls to builtin functions. If any of them
    % match up, then we have a winner!
    BANNED_OPS = {'__BANG', '__PARFOR', '__SPMD', '__GLOBAL'};
    bannedFunName = calls(ismember(calls, [banned BANNED_OPS]));
    mask = strncmp(bannedFunName, '__', 2);
    bannedFunName(mask) = ...
        strjoin(cellfun(@(s)(s(3:end)), bannedFunName(mask), 'uni', false), ', ');
    isBanned = ~isempty(bannedFunName);
end

function calls = getCalls(path, ignore)
    if nargin == 1
        ignore = {};
    end
    [fld, name, ~] = fileparts(path);
    info = mtree(path, '-file');
    calls = info.mtfind('Kind', {'CALL', 'DCALL'}).Left.stringvals;
    atCalls = info.mtfind('Kind', 'AT').Tree.mtfind('Kind', 'ID').stringvals;
    innerFunctions = info.mtfind('Kind', 'FUNCTION').Fname.stringvals;
    % any calls to inner functions should die
    calls = [calls, atCalls];
    calls(ismember(calls, [innerFunctions ignore])) = [];

    % For any calls that exist in our current directory, recursively
    % collect their builtin calls
    localFuns = dir([fld filesep '*.m']);
    localFuns = {localFuns.name};
    localFuns = cellfun(@(s)(s(1:end-2)), localFuns, 'uni', false);
    localCalls = calls(ismember(calls, localFuns));
    calls(ismember(calls, localFuns)) = [];
    for l = 1:numel(localCalls)
        calls = [calls getCalls([pwd filesep localCalls{l} '.m'], [ignore {name}])]; %#ok<AGROW>
    end

    % add any operations
    OPS = {'BANG', 'PARFOR', 'SPMD', 'GLOBAL'};
    calls = [calls compose('__%s', string(info.mtfind('Kind', OPS).kinds))];
    calls = unique(calls);
end