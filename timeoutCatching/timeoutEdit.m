function timeoutEdit(fname, timeout)
%% define stuff
funcName = strtok(fname, '.');
INIT = sprintf('\nif (length(dbstack) > 2 && dbstack(3).file == %s); tic; end\n', funcName);
BREAK = sprintf('\nif toc > %d; error(''Execution timed out after %d seconds''); end\n', timeout, timeout);
% REC_CHECK_FUN = sprintf('\nfunction bool = recursiveCallCheck(fname)\nd = dbstack;\nif length(d) > 2 && d(3).file == fname\n    bool = true;\nelse\n    bool = false;\nend\nend\n');

% regular expression that matches any contiguous block of comments
% just trust that this one works
commentRegEx = '((\s*%[^{}][^\n\r]*)|(\s*%{\s*(\r|\n)+((?!%}\s*(\n|\r)).)*%}\s*(\n|\r))|(\s*%({|})\s*\w*[^\n\r]*))+';

% look for where the word "function" and the name of the main function appear on the same
% line and determine that this is the function header
headerRegEx = ['\s*function[^\n\r]*', funcName, '[^\n\r]*'];

% regex to find strings
stringRegEx = '''((?!''.).)*''';
stringPlaceholder = '<>';

text = fileread(fname);

%% prep stuff
% first remove all comments so they don't interfere with parsing
justCode = strjoin(regexp(text, commentRegEx, 'split'), '\n');

% next figure out where the initial "tic" call should go
initIdx = regexp(justCode, headerRegEx, 'end');

% tries to account for misnamed function
if isempty(initIdx)
    warning('Could not identify properly named main function in %s. Now matching any function definition.', fname);
    headerRegEx = '\s*function[^\n\r]*';
    initIdx = regexp(justCode, headerRegEx, 'end');
end

% tries to account for possibility of infinite script (should never happen)
if isempty(initIdx)
    warning('Could not identify any function header. Defaulting to insert toc at beginning of file');
    initIdx = 1;
end

% account for multiple function matches (should only happen if misnamed function)
if length(initIdx) > 1
    warning('Multiple function header matches found in %s', fname);
    initIdx = initIdx(1);
end

%% do stuff
% now put placeholders in for all the string literals in the file
strings = regexp(justCode, stringRegEx, 'match');
justCode = regexprep(justCode, stringRegEx, stringPlaceholder);

% now all instances of "end" are acutally in code
% replace all "end"s with break statement
% (easier than trying to figure out specifically where they need to go)
% TODO need to replace this with regular expression that will exclude end as an
% index keyword
justCode = strrep(justCode, 'end', [BREAK, sprintf('end\n')]);

% stick the initial toc call at the beginning of the main function
justCode = [justCode(1:initIdx), INIT, justCode(initIdx+1:end)];

% put strings back where they came from
for i = 1:length(strings)
    idx = strfind(justCode, stringPlaceholder);
    justCode = [justCode(1:idx-1), strings{i}, justCode(idx+2:end)];
end

%% write stuff
% put the recursive check function at the end
% justCode = [justCode, REC_CHECK_FUN];
fh = fopen([funcName, '_finite.m'], 'w');
fprintf(fh, '%s', justCode);
fclose(fh);
end