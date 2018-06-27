%% fileDiff: Produce the HTML file diff for two files
%
% H = fileDiff(T1, T2) will use text T1 and T2 to create a "visdiff" for
% the two input texts, returning prettified HTML.
%
% H = fileDiff(T1, T2, I) will do the same as above, but will output the
% "boilerplate" HTML.
%
%%% Remarks
%
% This function serves as a replacement for visdiff, which has proved
% unweildy and, ultimately, not usable for our purposes.
%
% The goal of this function is to create modular HTML markup that utilized
% Bootstrap's grid to return meaningul and, ultimately, responsive HTML.

function html = fileDiff(txt1, txt2, fName1, fName2, isBoilerplate)
EQUAL = '<span class="diff-equal">%s</span>';
DELETE = '<span class="diff-delete">%s</span>';
INSERT = '<span class="diff-insert">%s</span>';
NODISP = '<span class="diff-invisible">%s</span>';
COLLAPSE = '%s<br/><br/><span class="diff-omitted">%d equal lines omitted</span><br/><br/>%s';
RESOURCES = {
                '<link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">', ...
                '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
                '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
                '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
                '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
                };
BOILER = [{'<!DOCTYPE html>', '<html>', '<head>', '<style>', ...
    'span {font-family: "Courier New"} .diff-equal {background-color: white;} .diff-delete {background-color: #FF8A8A; text-decoration: line-through;} .diff-insert {background-color: lightgreen;} .diff-invisible {color: white;} .diff-omitted {color:#b5b5b5;}', ...
    '</style>'}, RESOURCES, {'</head>', '<body>'}];
EQUAL_COLLAPSE_LINE_NUM = 5;
COLLAPSE_NUM = 2;
if nargin == 2
    isBoilerplate = true;
end
    javaaddpath([fileparts(mfilename('fullpath')) filesep 'diffMatchPatch.jar']);
    cleaner = onCleanup(@()(...
        javarmpath([fileparts(mfilename('fullpath')) filesep 'diffMatchPatch.jar'])));
    dmp = diff_match_patch();
    diffs = dmp.diff(txt1, txt2);
    
    % for each diff of left side, print accordingly?
    if isBoilerplate
        html = [BOILER {'<div class="row file-diff">'}];
    else
        html = {'<div class="row file-diff">'};
    end
    
    left = {'<div class="col-sm-6 file-diff-left">', '<h2 style="font-size: 4vw;">', sanitize(fName1), '</h2>', '<div class="diff-content">', ''};
    right = {'<div class="col-sm-6 file-diff-right">', '<h2 style="font-size: 4vw;">', sanitize(fName2), '</h2>', '<div class="diff-content">', ''};
    
    d = 0;
    while d < diffs.size()
        diff = diffs.get(d);
        txt = char(diff.text);
        % each diff keeps return symbols, so just rely on CLASSES
        % if equal, print both same
        if diff.operation == diff.operation.EQUAL
            % see how many more are equal; if past const, then collapse
            if numel(strfind(txt, newline)) >= EQUAL_COLLAPSE_LINE_NUM
                lns = strsplit(txt, newline);
                starter = strjoin(lns(1:COLLAPSE_NUM), newline);
                ender = strjoin(lns(end-COLLAPSE_NUM:end), newline);
                txt = sprintf(COLLAPSE, ...
                    sanitize(starter), ...
                    numel(strfind(txt, newline)) - (2 * COLLAPSE_NUM), ...
                    sanitize(ender));
            else
                txt = sanitize(txt);
            end
            rightLine = sprintf(EQUAL, txt);
            leftLine = sprintf(EQUAL, txt);
        elseif diff.operation == diff.operation.DELETE
            rightLine = sprintf(NODISP, sanitize(txt));
            leftLine = sprintf(DELETE, sanitize(txt));
        elseif diff.operation == diff.operation.INSERT
            rightLine = sprintf(INSERT, sanitize(txt));
            leftLine = sprintf(NODISP, sanitize(txt));
        else
            rightLine = '';
            leftLine = '';
        end
        left{end} = [left{end} leftLine];
        right{end} = [right{end} rightLine];
        d = d + 1;
    end
    clear diff;
    clear diffs;
    clear dmp;
    left = [left {'</div>', '</div>'}];
    right = [right {'</div>', '</div>'}];
    if isBoilerplate
        html = [html left right '</div>' '</body>', '</html>'];
    else
        html = [html left right '</div>'];
    end
    html = strjoin(html, newline);
    
end

function line = sanitize(line)
    line = strrep(line, '&', '&amp;');
    line = strrep(line, '<', '&lt;');
    line = strrep(line, '>', '&gt;');
    line = strrep(line, newline, '<br />');
end