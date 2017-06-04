%% cleanLines: Clean MATLAB function file contents
%
% [C, B] = cleanLines(LINES, OPTIONS)
%
% Given LINES, a cell array of character vectors or a string array, 
% cleanLines will return the same LINES with the following removed:
% 
% * Comments
% * EVAL statements
% * Blank Lines
% * System Calls
%
% In general, C will be of the same class as LINES, except in the
% following cases:
% 
% * If LINES is a single character vector, cleanLines will attempt to open
% the string as a file. It will return by default a cell array.
% * If LINES is a double, cleanLines will attempt to use this double as a
% file handle. It will return by default a cell array, and will not modify
% the existing file handle.
%
% If OPTIONS is given, it should be a structure that can contain any
% combination of the following fields:
%
% * eval:       If true, eval commands (and arguments, outputs) will be
% removed.
% * blank:      If true, blank lines will be removed.
% * system:     If true, any system calls (via system or "!") will be
% removed.
% * char:       If true, all character arrays will also be removed.
% * string:     If true, this will force the output to be a string array.
% * func:       If present, this should be a cell array or string array of
% function names, given as either strings, character vectors, or function
% handles. If any are found, they'll be removed.
%
% If OPTIONS is given, eval, blank, and system default TRUE, char 
% and string default FALSE, and func defaults to {}.
%
% If OPTIONS.func is given, B will be a cell array of banned functions
% found in the student file.
%
% NOTE: A line is considered blank IFF there is no executable code on the
% line. Also, note that all trailing space is removed. Also, note that
% comments will ALWAYS be removed.
%
% cleanLines will throw an illegalArguments exception if no arguments are
% given.
%
% If the first argument is of type char, but not the valid name of a file,
% cleanLines will throw a fileDoesNotExeist exception.
%
% If the first argument is of class double, but not a valid file handle,
% cleanLines will throw a illegalFileHandle exception.
%
% If the first argument is a cell array with mixed contents, cleanLines 
% will throw an illegalArguments exception.
%
% If the second argument is given and is NOT a scalar structure,
% cleanLines will throw an illegalArguments exception.
%
% If the second argument contains an unknown field name, cleanLines will
% throw an illegalFieldName exception.
%
% If the second argument contains an unknown field value, cleanLines will
% thrown an illegalFieldValue exception.
%
% Examples:
%
%   lines = {'function out = myFun(in)', '%%HelloWorld', 'end'};
%   lines = cleanLines(lines);
%   % lines -> {'function out = myFun(in)'; 'end'}
%
%   lines = {'function myFun() %hello'; '%% what'; '     '; 
%   '!echo "hello"'; 'eval(''helloWorld'');'; 'disp([''hello'' ...HI!';
%   '''world'']);'; 'end'};
%   lines = cleanLines(lines);
%   % lines -> {'function myFun()'; 'disp([''hello'' ...'; '''world''])'; 
%   'end'}
%
%   lines = {'function myFun()%hello'; '%% what'; '     '; '!echo hello';
%   'eval(''hello'');'; 'disp([''hello'' ...H'; '''world'']);'; 'end'};
%   options = struct('char', true);
%   lines = cleanLines(lines, options);
%   % lines -> {'function myFun()', '', '', '!echo "hello"', 'eval();', 
%   'disp(['; ']);', 'end'};
%
%   % In file badFun.m
%      function bad = badFun(bad)
%       % This is a tester function
%       % It has the worst student code EVAR
%       %{
%       %{
%       killAll
%       eval()
%       eval = 1
%       %}
%       %}
%
%       eval = 1;
%       system = 3;
%       length(5)
%
%       length(4); a = 1;
%   lines = cleanLines('badFun.m');
%   % lines -> {'function bad = badFun(bad)', 'eval = 1;', 'system = 3;',
%   'length(4); a = 1;'}
%
%   lines = cleanLines('badFun.m', struct('func', {{'length'}});
%   % lines -> {'function bad = badFun(bad)', 'eval = 1;', 'system = 3;',
%   'a = 1;'}
%
%   fid = fopen('badFun.m', 'x') % opened in either read OR write mode
%   lines = cleanLines(fid);
%   % lines -> {'function bad = badFun(bad)', 'eval = 1;', 'system = 3;',
%   'length(4); a = 1;'}
%   % fid -> same as before
%
% Examples with Exceptions:
%   lines = cleanLines(-1) % -1 is not a valid file handle!
%   % Exception Thrown: 'illegalFileHandle': 'Illegal file handle given.'
%
%   lines = cleanLines('') % '' is not a valid file!
%   % Exception Thrown: ':fileDoesNotExist'L 'Given file  does not exist.'

%% Function
function [lines, banned] = cleanLines(lines, options)
%% Input Sanitization
if nargin == 2
    if ~isstruct(options) || numel(options) ~= 1
        throw(MException('autoGrader:cleanLines:illegalArguments', 'Options given are not formatted correctly.'));
    else
        fields = fieldnames(options);
        ALLOWED_FIELDS = {'comment', 'eval', 'blank', 'system', 'char', 'string', 'func'};
        if ~all(cellfun(@(str)(any(strcmpi(str, ALLOWED_FIELDS))), fields))
            fields = fields(~cellfun(@(str)(any(strcmpi(str, ALLOWED_FIELDS))), fields));
            err = strjoin(fields, ', ');
            throw(MException('autoGrader:cleanLines:illegalFieldName', 'Illegal field name %s.', err));
        end
        if ~all(cellfun(@(f)(islogical(options.(f))), fields(~strcmpi(fields, 'func'))))
            fields = fields(~cellfun(@(f)(islogical(options.(f))), fields));
            fields(strcmpi(fields, 'func')) = [];
            err = strjoin(fields, ', ');
            throw(MException('autoGrader:cleanLines:illegalFieldValue', 'Illegal field value given in field(s) %s.', err));
        end
        for k = ALLOWED_FIELDS(1:end-3)
            if ~any(strcmp(k{1}, fields))
                options.(k{1}) = true;
            end
        end
        for k = ALLOWED_FIELDS((end-2):(end-1))
            if ~any(strcmp(k{1}, fields))
                options.(k{1}) = false;
            end
        end
        if ~any(strcmp('func', fields))
            options.func = {};
        else
            funcs = options.func;
            if iscell(funcs)
                if all(cellfun(@ischar, funcs))
                    [funcs, ~] = strtok(funcs, '.');
                else
                    for k = 1:numel(funcs)
                        if isa(funcs{k}, 'function_handle')
                            funcs{k} = func2str(funcs{k});
                        elseif ischar(funcs{k})
                            [funcs{k}, ~] = strtok(funcs{k}, '.');
                        else
                            throw(MException('autoGrader:cleanLines:illegalFieldValue', 'Illegal field Value given in field(s) %s.', 'func'));
                        end
                    end
                end
            elseif isstring(funcs)
                [funcs, ~] = strtok(cellstr(funcs), '.');
            else
                throw(MException('autoGrader:cleanLines:illegalFieldValue', 'Illegal field value given in field(s) %s.', 'func'));
            end
            options.func = funcs;
        end
    end
elseif nargin == 1
    options = struct('comment', true, 'eval', true, 'blank', true, 'system', true, 'string', false, 'func', {{}});
else
    throw(MException('autoGrader:cleanLines:illegalArguments', 'No arguments given.'));
end
if isstring(lines)
    options.string = true;
    lines = cellstr(lines);
elseif ischar(lines)
    fid = fopen(lines, 'r');
    if fid < 3
        throw(MException('autoGrader:cleanLines:fileDoesNotExist', 'Given file %s does not exist.', lines));
    else
        lines = textscan(fid, '%s', 'Delimiter', '\n');
        lines = lines{1};
        fclose(fid);
    end
elseif isnumeric(lines)
    fid = fopen(fopen(lines), 'r');
    try
        lines = textscan(fid, '%s', 'Delimiter', '\n');
        lines = lines{1};
        fclose(fid);
    catch ME
        throw(MException('autoGrader:cleanLines:illegalFileHandle', 'Illegal file handle given.'));
    end
elseif iscell(lines)
    if  ~all(cellfun(@ischar, lines))
        throw(MException('autoGrader:cleanLines:illegalArguments', 'Mixed lines given.'));
    end
else
    throw(MException('autoGrader:cleanLines:illegalArguments', 'Illegal argument given.'));
end

%% Removing Comments
% To remove comments, we first remove block comments. To do this, we first
% find ALL %{ that are by themselves.
% BEFORE we do that, however, let's remove trailing spaces.
lines = regexprep(lines, '(?<=\S)\s+$', '');

% We should combine any lines that end in ... with the line below it:
for k = (numel(lines) - 1):-1:1
    ellipse = regexp(lines{k}, '(?<![^'']\w?.*'')\.\.\..*$');
    if ~isempty(ellipse)
        lines{k}(ellipse:end) = [];
        lnEnd = regexp(lines{k + 1}, '(?<![^'']\w?.*'');');
        lines{k} = [lines{k} ' ' lines{k + 1}(1:lnEnd)]; 
        lines{k + 1}(1:lnEnd) = [];
    end
end
% Now we can remove block comments!
% If we join them back up, we can clear the block comments in one fell
% swoop
lines = strjoin(lines, '\n');
% The start MUST be %{\n EXACTLY!
lines = regexprep(lines, '%{\n.*%?}', '');
lines = strsplit(lines, '\n');
% Now we can look at individual lines:
lines = regexprep(lines, '(?<![^'']\w?.*'')%.*$', '');

%% Removing EVAL statements
% Wherever we find EVAL used AS A FUNCTION, we should delete both it AND
% IT'S ARGUMENTS

% To do this, we need to first figure out if it was ever used AS A VAR!
if options.eval
    asVar = regexp(lines, '(?<![^'']\w?.*'')eval\s*=');
    if ~isempty(asVar)
        temp = cellfun(@isempty, asVar);
        asVar = find(~temp, 1);
        evalLines = lines(1:(asVar - 1));
    else
        evalLines = lines;
    end
    evalLines = regexprep(evalLines, '(?<![^'']\w?.*'')eval?.*?(;|,|$)', '');
    lines(1:(asVar - 1)) = evalLines;
end

%% Removing System Calls
if options.system
    lines = regexprep(lines, '(?<![^'']\w?.*'')!.*$', '');
    asVar = regexp(lines, '(?<![^'']\w?.*'')system\s*=');
    if ~isempty(asVar)
        temp = cellfun(@isempty, asVar);
        asVar = find(~temp, 1);
        sysLines = lines(1:(asVar - 1));
    else
        sysLines = lines;
    end
    sysLines = regexprep(sysLines, '(?<![^'']\w?.*'')system?.*?(;|,|$)', '');
    lines(1:(asVar - 1)) = sysLines;
end

%% Removing Banned Functions
% If we find a banned function, replace it with ''.
banned = false(size(options.func));
for k = 1:numel(options.func)
    asVar = regexp(lines, ['(?<![^'']\w?.*'')' options.func{k} '\s*[^;,]=']);
    if ~isempty([asVar{:}])
        temp = cellfun(@isempty, asVar);
        asVar = find(~temp, 1);
        funcLines = lines(1:(asVar - 1));
    else
        asVar = numel(lines) + 1;
        funcLines = lines;
    end
    foundLines = regexp(funcLines, ['(?<![^'']\w?.*'')' options.func{k} '?.*(;|,|$)']);
    if ~all(cellfun(@isempty, foundLines))
        banned(k) = true;
        lines(1:(asVar - 1)) = regexprep(funcLines, ['(?<![^'']\w?.*'')' options.func{k} '?.*?(;|,|$)'], '');
    end
end
banned = options.func(banned);

%% Removing Blank Lines
if options.blank
    lines = regexprep(lines, '^\s*$', '');
    lines(cellfun(@isempty, lines)) = [];
end

%% Reformatting
lines = regexprep(lines, '(?<=\S)\s+$', '');
if options.string
    lines = string(lines);
    banned = string(banned);
end

end