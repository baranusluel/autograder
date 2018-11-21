%% NoTestStudent
% Collection of students, but no test

function [passed, msg] = test

fid = fopen('names.txt', 'rt');
originalNames = string(strsplit(char(fread(fid)'), newline));
fclose(fid);

% Randomize the names
randomizedNames = originalNames(randperm(numel(originalNames)));
while isequal(randomizedNames, originalNames)
    randomizedNames = originalNames(randperm(numel(originalNames)));
end

try
    [sortedNames, inds] = canvasSort(randomizedNames);
catch e
    msg = sprintf('Expected sort; got exception %s', e.message);
    passed = false;
    return;
end

if ~isequal(sortedNames, originalNames)
    passed = false;
    ind = find(sortedNames ~= originalNames);
    msg = sprintf('Incorrectly sorted; first mismatch was %d (%s -> %s)', ...
        ind(1), char(sortedNames(ind(1))), char(originalNames(ind(1))));
elseif ~isequal(originalNames, randomizedNames(inds))
    passed = false;
    ind = find(sortedNames ~= originalNames);
    msg = sprintf('Indices incorrectly sorted; first mismatch was %d (%s -> %s)', ...
        ind(1), char(sortedNames(ind(1))), char(originalNames(ind(1))));
else
    passed = true;
    msg = '';
end
end