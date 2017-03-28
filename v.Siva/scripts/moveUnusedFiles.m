filename = '../architecture.txt';
fh = fopen(filename);
line = fgetl(fh);
files = {};
while ischar(line)
    line = strtok(line);
    files{end+1} = [line, '.m'];
    line = fgetl(fh);
end
fclose(fh);

cd '..';
fh_getDirectoryContents = @getDirectoryContents;
cd 'scripts';

directoryContents = fh_getDirectoryContents('../unused', false, true);

if ~isempty(directoryContents)
    movefile('../unused/*', '../');
end

directoryContents = fh_getDirectoryContents('..', false, true);
for ndxFile = 1:length(directoryContents)
    [~, ~, ext] = fileparts(directoryContents(ndxFile).name);
    if ~any(strcmp(directoryContents(ndxFile).name, files)) && strcmp(ext, '.m')
        movefile(['../' directoryContents(ndxFile).name], '../unused');
    end
end