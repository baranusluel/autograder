% CALLED BY:
%       getFunctionHandles.m
function functions = getFunctions(location)

    directory = getDirectoryContents(location, false, true);
    isMatlabFile = cellfun(@(x) strcmp(x(end-1:end), '.m'), {directory.name});
    functions = cellfun(@(x) x(1:end-2), {directory(isMatlabFile).name}, 'UniformOutput', false);

end