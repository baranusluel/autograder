%{
Recursively search all contents of current directory and find the file specified
If multiple matches are found, the most recently modified version of the file
is returned

Otuput is a file path to the file relative to the current path.
if the file is found, an error is thrown.
%}
function relPath = findFile(file)
if isempty(file)
    error('File cannot be empty');
end
d = rdir(fullfile(pwd, '**', '*'));
[~, sort_by_edit_date] = sort([d.datenum], 'descend');
d = d(sort_by_edit_date);
names = {d.name};
idx = find(cellfun(@(x) ~isempty(strfind(x, file)), names), 1);
if isempty(idx)
    error('Could not find %s in any subdirectory of %s', file, pwd);
else
    relPath = strrep(names{idx}, [pwd, filesep], '');
end
end