%% canvasSort: Sort names, Canvas Style
%
% canvasSort will sort a list of names in the order that Canvas would sort
% them.
%
% S = canvasSort(N) will sort names N according to the rules that govern 
% Canvas sorting, and return them sorted in S.
%
% [S, I] = canvasSort(N) will do the same, but will also return the indices
% needed to convert from N to S.
%
%%% Remarks
%
% Canvas' sorting methods are... bizarre. We have codified the rules below:
%
% * Case Insensitve
% * Hyphens are sorted before commas
% * If the test student exists, always placed after
%
% N can either be a cell array of character vectors, a string array, or a
% character vector.
%
function [sorted, inds] = canvasSort(names)
    if ischar(names)
        names = string(names);
    elseif iscell(names)
        names = string(names);
    end
    % Case Insensitive
    % The sort is case insensitive.
    sortableNames = lower(names);

    % Hyphens before Commas
    % Commas appear after hyphens...
    sortableNames = strrep(sortableNames, ",", ".");

    % The Sort
    % Let's test the sort and see what happens!
    [~, inds] = sort(sortableNames);
    sorted = names(inds);

    % Test Student
    % The Test Student will always be placed at the end
    mask = strcmp(sorted, 'Student, Test');
    if any(mask)
        sorted(end+1) = sorted(mask);
        inds(end+1) = inds(mask);
        sorted(mask) = [];
        inds(mask) = [];
    end
end