%% jaccardIndex: Give the jaccardIndex for two files
%
% jaccardIndex gives the jaccardIndex for two code files.
%
% [R1, R2] = jaccardIndex(F1, F2) Uses the code file paths F1 and F2 to
% construct jaccard indices R1 and R2, respectively, using the Minumum
% Comparison Index.
%
% [R1, R2] = jaccardIndex(F1, F2, P) does the same as above, but uses up to
% P permutations.
%
%%% Remarks
%
% The similarity between these two ranks can be used to see how similar two
% files are. R1 and R2 are guaranteed to be the same length, though there
% are no guarantees how the length relates to either file size.
%
%%% Exceptions
%
% An AUTOGRADER:jaccardIndex:invalidFile exception will be thrown if either
% file cannot be read.

function [rank1, rank2] = jaccardIndex(txt1, txt2, perm)
    if nargin == 2
        perm = Inf;
    end
    
    % split into words
    if ischar(txt1)
        txt1 = strsplit(txt1, '\s+', 'DelimiterType', 'RegularExpression');
    end
    if ischar(txt2)
        txt2 = strsplit(txt2, '\s+', 'DelimiterType', 'RegularExpression');
    end
    
    txt = unique([txt1 txt2]);
    perm = min([perm, length(txt)]);
    
    % randomly permute NUM_PERMUTATIONS times, and store minimum index
    rank1 = zeros(1, perm);
    rank2 = zeros(1, perm);
    
    for i = 1:perm
        % randomly permute
        inds = randperm(numel(txt));
        tmp = txt(inds);
        % iterate until BOTH ranks ~= 0
        level = 1;
        while level <= length(tmp) && (rank1(i) == 0 || rank2(i) == 0)
            if rank1(i) == 0 && any(contains(txt1, tmp{level}, 'IgnoreCase', true))
                rank1(i) = level;
            end
            if rank2(i) == 0 && any(contains(txt2, tmp{level}, 'IgnoreCase', true))
                rank2(i) = level;
            end
            level = level + 1;
        end
    end
end