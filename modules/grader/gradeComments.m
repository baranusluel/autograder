%% gradeComments: Grade Comments for file
%
% gradeComments parses a file and grades the comments.
%
% P = gradeComments(F) will grade the code file F and give points P, where P
% falls between 0 and 10.
%
% P = gradeComments(F, D) will do the same as above, but will use dictionary
% D instead. D must be a cell array of character vectors.
%
%%% Remarks
%
% The comment grader assigns points based on three criteria:
%
% * The ratio of comments to the total number of lines
% * The number of those comments that appear in the dictionary
% * The spread of those comments
%
% The perfect file would have around a third of the file be comments, 80%
% of those words be english, and comments evenly spread.
%
% The behavior of gradeComments can be tuned by changing the constants.
%
%%% Exceptions
%
% This will not throw an exception
function points = gradeComments(file, dict)
    FMT = ' %s ';
    persistent dictionary;
    if nargin < 2
        dict = [fileparts(mfilename('fullpath')) filesep 'dictionary.txt'];
    end
    if isempty(dictionary)
        fid = fopen(dict, 'rt');
        dictionary = strsplit(char(fread(fid)'), newline);
        dictionary(cellfun(@isempty, dictionary)) = [];
        fclose(fid);
        dictionary = compose(FMT, string(dictionary));
    end
    if nargin == 0 || isempty(file)
        points = 0;
        return;
    end
    % Max # of points to be assigned for # of comment lines
    MAX_LINE_POINTS = .5;
    % Max # of points to be assigned for words appearing in dictionary
    MAX_DICT_POINTS = .3;
    % Max # of points to be assigned for spread
    MAX_SPRD_POINTS = .2;
    % Ideal ratio for lines of comments to lines of code:
    IDEAL_LINE_RATIO = 1/3;
    % Ideal ratio of in-dictionary words to overall # of words
    IDEAL_WORD_RATIO = .8;
    % Ideal distance between comment lines
    IDEAL_COMM_DIST = 3;
    % Maximum distance from ideal for any points for spread
    MAX_COMM_DIST = 10;
    % Minimum # of comments. Must be greater than 1
    MIN_LINE_NUM = 2;
   
    fid = fopen(file, 'rt');
    code = char(fread(fid)');
    fclose(fid);
    % find all combinations, replace with NULL character.
    % this is to account for weird encodings that a student used.
    code = strrep(code, [char(10) char(13)], char(0)); %#ok<*CHARTEN>
    code = strrep(code, [char(13) char(10)], char(0));
    code = strrep(code, char(13), char(10));
    code = strrep(code, char(0), char(10));
    code = strrep(code, char(10), newline);
    % get rid of blank lines
    lines = strsplit(code, newline, 'CollapseDelimiters', true);
    code = strjoin(lines, newline);
    
    data = mtree(code);
    inds = unique(data.getlastexecutableline);
    codeLines = false(1, numel(lines));
    codeLines(inds) = true;
    commLines = true(1, numel(lines));
    commLines(inds) = false;
    if sum(commLines) <= MIN_LINE_NUM
        points = 0;
        return;
    end
    % get spread of commLines
    spreadLines = find(commLines);
    
    avgSpread = mean(diff(spreadLines));
    % assign these points
    dist = abs(avgSpread - IDEAL_COMM_DIST);
    if avgSpread <= IDEAL_COMM_DIST
        points = MAX_SPRD_POINTS;
    elseif dist <= MAX_COMM_DIST
        points = MAX_SPRD_POINTS * (1 - (dist / MAX_COMM_DIST));
    else
        points = 0;
    end
    
    % get number of code lines vs number of comment lines
    if sum(codeLines) == 0
        return;
    end
    ratio = sum(commLines) / numel(lines);
    
    if ratio < IDEAL_LINE_RATIO
        dist = abs(ratio - IDEAL_LINE_RATIO) / IDEAL_LINE_RATIO;
    else
        dist = 0;
    end
    points = points + MAX_LINE_POINTS * (1 - dist);
        
    lines(codeLines) = [];
    % lines are just comments; split into words and see what words are
    % contained in dictionary
    code = strjoin(lines, ' ');
    code(~isletter(code) & code ~= ' ') = [];
    words = compose(FMT, string(strsplit(code, ' ')));
    if numel(words) == 0
        return;
    end
    
    numInDict = sum(contains(words, dictionary, 'IgnoreCase', true));
    ratio = numInDict / numel(words);
    if ratio >= IDEAL_WORD_RATIO
        points = points + MAX_DICT_POINTS;
    else
        dist = abs(ratio - IDEAL_WORD_RATIO) / IDEAL_WORD_RATIO;
        points = points + MAX_DICT_POINTS * (1 - dist);
    end
end