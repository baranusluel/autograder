%% readmeParser: Parse a README into valid HTML
%
% Given a README file path, create valid HTML
%
% readmeParser(P) will create a valid HTML file from the given README in 
% the same place. readmeParser will overwrite any data already there,
% though the original README file is unchanged.
%
% H = readmeParser(L) will create a valid HTML string from the given cell
% array or string array of lines from the README.
%
% H = readmeParser(P) will do the exact same thing as H = readmeParser(L),
% but will instead read from the given path
%
% This function is under construction, but may not actually ever be
% finished...
function html = readmeParser(var, baseUrl)
if ~exist('baseUrl', 'var');
    baseUrl = 'https://github.gatech.edu/CS1371/autograder/wiki/';
end
    if iscell(var)
        html = parser(var, baseUrl);
        if nargout == 0
            clear('html');
        end
    else
        fid = fopen(var, 'r+');
        lines = textscan(fid, '%s', 'Delimiter', {'\n'}, 'Whitespace', '');
        fclose(fid);
        lines = lines{1};
        html = parser(lines, baseUrl);
        if nargout == 0
            [path, name, ~] = fileparts(var);
            fid = fopen([path name '.html'], 'w+');
            fwrite(fid, html);
            fclose(fid);
            clear('html');
        end
    end
end
function html = parser(lines, baseUrl)
    % if line starts with any number of #, turn into h1-6
    % if line starts with -, turn into ul
    % if line starts with *, BUT NO ENDING * AND NOT **, turn into ul
    % if line starts with #., turn into ol
    % if **stuff**, then it's bold
    % if _stuff_, then it's italic
    % if `stuff`, then it's pre (?)
    % if line ```, then all lines until ``` are pre (?)
    % if line isn't blank, read to next until blank line for innards of p
    
    html = {'<!DOCTYPE html>', '<html>', '<head>', '<meta charset="utf-8">', ...
        '<meta name="viewport" content="width=device-width, initial-scale=1">', '</head>', '<body>', ...
        '</body>', '</html>'};
    % Add scripts, etc.
    scripts = {'<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
        '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>'};
    links = {'<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">'};
    style = {'<style>', 'pre.bg-light {', '    border-radius: 5%;', '}', ...
        'pre.bg-light {', '    padding-left: 15px;', '}', '</style>'};
    html = [html(1:findHead(html)) scripts links style html((findHead(html)+1):end)];
    body = {'<div class="container-fluid">', '<div class="row">', '<div class="col-12">'};
    setTitle = false;
    i = 1;
    while i <= numel(lines)
        line = lines{i};
        % if line starts with any number of #, turn into h1-6
        % if line starts with -, turn into ul
        % if line starts with *, BUT NO ENDING * AND NOT **, turn into ul
        % if line starts with #., turn into ol
        % if **stuff**, then it's bold
        % if _stuff_, then it's italic
        % if `stuff`, then it's pre (?)
        % if line ```, then all lines until ``` are pre (?)
        % if [stuff](stuff), link
        % if line isn't blank, read to next until blank line for innards of p
        if ~isempty(line)
            if ~isempty(regexp(line, '^#{1,6}(?!#)', 'match', 'once'))
                heading = regexp(line, '^#{1,6}(?!#)', 'match');
                heading = heading{1};
                line = line((length(heading)+2):end);
                if ~setTitle && length(heading) == 1
                    % set title
                    t = {'<title>' line '</title>'};
                    html = [html(1:findHead(html)) t html((findHead(html)+1):end)];
                    setTitle = true;
                end
                line = parseLine(line, baseUrl);
                body = [body {['<h' num2str(length(heading)) '>']}, {line}, {['</h' num2str(length(heading)) '>']}];
                i = i + 1;
            elseif (line(1) == '*' || line(1) == '-') && line(2) == ' '
                body = [body {'<ul>'}];
                line = regexprep(line, '^^([-*])\s+', '');
                line = parseLine(line, baseUrl);
                body = [body {'<li>'}, {'<p>'}, {line}, {'</p>'}];
                indLevel = 0;
                % look at line below. If at higher indentation than our own,
                % add ul. If at same indentation, end li. If at lower
                % indentation, end li and ul. If blank, end ul.

                % if at end, end all open uls?
                if i == numel(lines)
                    body = [body {'</li>'}];
                    for j = 1:indLevel
                        body = [body {'</ul>'} {'</li>'}];
                    end
                    body = [body {'</ul>'}];
                else
                    i = i + 1;
                    line = lines{i};
                    checker = strip(lines{i});
                    while ~isempty(checker) && ((checker(1) == '-' || checker(1) == '*') && checker(2) == ' ') && i ~= numel(lines)
                        % not a blank line
                        % Not blank, engage.
                        % check ind level
                        [ind] = regexp(line, '^\s*', 'match');
                        if ~isempty(ind)
                            thisLevel = length(ind{1}) / 2;
                        else
                            thisLevel = 0;
                        end
                        if thisLevel == indLevel
                            % end li, begin new li with next li
                            line = regexprep(line, '^\s*[-*]\s+', '');
                            line = parseLine(line, baseUrl);
                            body = [body {'</li>'}, {'<li>'}, {'<p>'}, {line}, {'</p>'}];
                        elseif thisLevel > indLevel
                            % Add ul to this li
                            line = regexprep(line, '^\s*[-*]\s+', '');
                            line = parseLine(line, baseUrl);
                            body = [body {'<ul>'}, {'<li>'}, {'<p>'}, {line}, {'</p>'}];
                            indLevel = thisLevel;
                        elseif thisLevel < indLevel
                            % for each level, end the ul then the li
                            body = [body {'</li>'}];
                            for j = 1:(indLevel - thisLevel)
                                body = [body {'</ul>'} {'</li>'}];
                            end
                            line = regexprep(line, '^\s*[-*]\s+', '');
                            line = parseLine(line, baseUrl);
                            body = [body {'<li>', '<p>', {line}, '</p>'}];
                            indLevel = thisLevel;
                        end
                        if i == numel(lines)
                            break;
                        end
                        i = i + 1;
                        line = lines{i};
                        checker = strip(line);
                    end
                    % We've reached a blank line. Engage accordingly
                    body = [body {'</li>'}];
                    for j = 1:indLevel
                        body = [body {'</ul>'} {'</li>'}];
                    end
                    body = [body {'</ul>'}];
                end
            elseif strncmp(line, '```', 3)
                % Preformatted block. Start pre tag and engage, doing NO
                % parsing of lines.
                body = [body {'<pre class="bg-light">'}];
                i = i + 1;
                line = lines{i};
                while ~strncmp(strip(line), '```', 3) && i ~= numel(lines)
                    body = [body {line}];
                    i = i + 1;
                    line = lines{i};
                end
                body = [body , {'</pre>'}];
            elseif length(line) > 1 && line(1) == '>' && line(2) == ' '
                % Block quote. Start a block quote, and end it when line no
                % longer begins with >
                line = parseLine(line(3:end));
                body = [body {'<blockquote class="blockquote">'}];
                qContents = line;
                i = i + 1;
                line = lines{i};
                while i <= numel(lines) && length(line) > 1 && line(1) == '>' && line(2) == ' '
                    line = parseLine(line(3:end), baseUrl);
                    qContents = [qContents ' ' qContents];
                    if i == numel(lines)
                        break;
                    end
                    i = i + 1;
                    line = lines{i};
                end
                body = [body {qContents} {'</blockquote>'}];
            elseif ~isempty(regexp(line, '^[-_*=]{3,}\s*$', 'once'))
                body = [body {'<hr />'}];
            else
                % We are at block. Loop through until next blank line, then let go
                body = [body {'<p>'}];
                pContents = '';
                line = lines{i};
                checker = strip(line);
                while ~isempty(checker)
                    line = parseLine(line, baseUrl);
                    pContents = [pContents ' ' line];
                    if i == numel(lines)
                        break;
                    end
                    i = i + 1;
                    line = lines{i};
                    checker = strip(line);
                end
                body = [body {pContents} {'</p>'}];
            end
        end
        i = i + 1;
    end
    html = [html(1:findBody(html)) body html((findBody(html)+1):end)];
end

function ind = findHead(lines)
    ind = find(strncmpi(lines, '<head', 5), 1);
end

function ind = findBody(lines)
    ind = find(strncmpi(lines, '<body', 5), 1);
end

function line = parseLine(line, baseUrl)
    % Only need to look for __, ****, ``, [](), and replace accordingly
    inds = regexp(line, '^[_]{1}|(?<=[^\\])[_]{1}');
    for i = inds((end - 1):-2:1)
        line = [line(1:(i - 1)) '<em>' line((i + 1):end)];
    end
    inds = regexp(line, '^[_]{1}|(?<=[^\\])[_]{1}');
    for i = inds(end:-1:1)
        line = [line(1:(i - 1)) '</em>' line((i + 1):end)];
    end
    
    inds = regexp(line, '^[*]{2}|(?<=[^\\])[*]{2}');
    for i = inds((end - 1):-2:1)
        line = [line(1:(i - 1)) '<strong>' line((i + 2):end)];
    end
    inds = regexp(line, '(?<=[^\\])[*]{2}(?![*])');
    for i = inds(end:-1:1)
        line = [line(1:(i - 1)) '</strong>' line((i + 2):end)];
    end
    
    inds = regexp(line, '^[`]{1}|(?<=[^\\])[`]{1}');
    for i = inds((end - 1):-2:1)
        line = [line(1:(i - 1)) '<code class="bg-light">' line((i + 1):end)];
    end
    inds = regexp(line, '^[`]{1}|(?<=[^\\])[`]{1}');
    for i = inds(end:-1:1)
        line = [line(1:(i - 1)) '</code>' line((i + 1):end)];
    end
    
    [links, lStart, lEnd] = regexp(line, '[\[]([^\]]+)[\]]\(([A-Za-z0-9\-._~%:/?#\[\]@!$&''()*+,;=]+)\)', 'tokens', 'start', 'end');
    % for each link, create it
    for i = numel(links):-1:1
        link = links{i};
        href = link{2};
        label = link{1};
        tag = ['<a href="' href '">', parseLine(label), '</a>'];
        % replace from lStart to lEnd
        line = [line(1:(lStart(i)-1)) tag line((lEnd(i)+1):end)];
    end
    
    [links, lStart, lEnd] = regexp(line, '[\[]{2}([^\]]+)[|]([a-zA-Z0-9_-]+)[\]]{2}', 'tokens', 'start', 'end');
    % for each internal link, create it
    for i = numel(links):-1:1
        link = links{i};
        href = [baseUrl link{2}];
        label = link{1};
        tag = ['<a href="' href '">', parseLine(label), '</a>'];
        line = [line(1:(lStart(i)-1)) tag line((lEnd(i)+1):end)];
    end
end