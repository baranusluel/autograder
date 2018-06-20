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
function html = fileDiff2(file1, file2, isBoilerplate)
EQUAL = '<span class="diff-equal">%s</span><br />';
DELETE = '<span class="diff-delete">%s</span><br />';
INSERT = '<span class="diff-insert">%s</span><br />';
NODISP = '<span class="diff-invisible">%s</span><br />';
RESOURCES = {
                '<link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">', ...
                '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
                '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
                '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
                '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
                '<script defer src="https://use.fontawesome.com/releases/v5.0.8/js/all.js"></script>'
                };
BOILER = [{'<!DOCTYPE html>', '<html>', '<head>', '<style>', ...
    'span {font-family: "Courier New"} .diff-equal {background-color: white;} .diff-delete {background-color: lightgreen;} .diff-insert {background-color: #FF8A8A; text-decoration: line-through;} .diff-invisible {color: white}', ...
    '</style>'}, RESOURCES, {'</head>', '<body>'}];
EQUAL_COLLAPSE_LINE_NUM = 3;
if nargin == 2
    isBoilerplate = true;
end
    javaaddpath([fileparts(mfilename('fullpath')) filesep 'diffMatchPatch.jar']);
    cleaner = onCleanup(@()(...
        javarmpath([fileparts(mfilename('fullpath')) filesep 'diffMatchPatch.jar'])));
    fid = fopen(file1, 'rt');
    txt1 = char(fread(fid)');
    fclose(fid);
    fid = fopen(file2, 'rt');
    txt2 = char(fread(fid)');
    fclose(fid);
    dmp = diff_match_patch();
    diffs = dmp.diff(txt1, txt2);
    
    % for each diff of left side, print accordingly?
    if isBoilerplate
        html = [BOILER {'<div class="row file-diff">'}];
    else
        html = {'<div class="row file-diff">'};
    end
    left = {'<div class="col-6 file-diff-left">', '<h2>', sanitize(file1), '</h2>', '<div class="diff-content">', ''};
    right = {'<div class="col-6 file-diff-right">', '<h2>', sanitize(file2), '</h2>', '<div class="diff-content">', ''};
    
    d = 0;
    while d < diffs.size()
        diff = diffs.get(d);
        txt = char(diff.text);
        % each diff keeps return symbols, so just rely on CLASSES
        % if equal, print both same
        if diff.operation == diff.operation.EQUAL
            % see how many more are equal; if past const, then collapse
            if numel(strfind(txt, newline)) >= EQUAL_COLLAPSE_LINE_NUM
                txt = sprintf('%d equal lines omitted', ...
                    numel(strfind(txt, newline)));
            end
            rightLine = sprintf(EQUAL, sanitize(txt));
            leftLine = sprintf(EQUAL, sanitize(txt));
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