%% getText: Extract text from a group of problem paths
%
% getText will extract the words, hash code, and number of lines from a
% group of problem file paths.
%
% T = getText(P) will use problem paths P to get text array T. T will be a
% string array of the words, hash code, and number of lines.
%
%%% Remarks
%
% getText is highly optimized to return values useful to jaccardIndexing.
% As such, the output is specifically tailored:
%
% * The first output is a sorted list of words that were in the original
% file.
% * The second output is the Java Hash Code for the original code
% * The third output is the number of lines.
%

function problemTxt = getText(problemPaths)
    for p = numel(problemPaths):-1:1
        if isempty(problemPaths{p})
            problemTxt{p} = cell(1, 2);
            problemTxt{p} = {"", 0, 0};
        else
            fid = fopen(problemPaths{p}, 'rt');
            code = char(fread(fid)');
            fclose(fid);
            % find all combinations, replace with NULL character.
            % this is to account for weird encodings that a student used.
            code = strrep(code, [char(13) char(10)], char(0)); %#ok<*CHARTEN>
            code = strrep(code, char(13), char(10));
            code = strrep(code, char(0), char(10));
            code = strrep(code, char(10), newline);
            tree = mtree(code);
            tmp = strsplit(code, newline, 'CollapseDelimiters', false);
            % remove comments
            problemTxt{p}{1} = ...
                string(strjoin(tmp(unique(tree.getlastexecutableline)), newline));
            problemTxt{p}{3} = numel(strfind(problemTxt{p}{1}, newline));
            problemTxt{p}{1} = sort(lower(strsplit(problemTxt{p}{1}, '\s+', 'DelimiterType', 'RegularExpression')));
            problemTxt{p}{2} = java.lang.String(code).hashCode;
        end
    end
end