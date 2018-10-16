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

function [rank1, rank2] = jaccardIndex(txt1, txt2, perm)
    if nargin == 2
        perm = Inf;
    end
    
    % split into words
    
    txt = unique([txt1 txt2]);
    perm = min([perm, length(txt)]);
    
    % randomly permute NUM_PERMUTATIONS times, and store minimum index
    rank1 = zeros(1, perm);
    rank2 = zeros(1, perm);
    
    for i = 1:perm
        % randomly permute
        inds = randperm(numel(txt));
        % iterate until BOTH ranks ~= 0
        level = 1;
        while level <= length(txt) && (rank1(i) == 0 || rank2(i) == 0)
            if rank1(i) == 0 && any(contains(txt1, txt(inds(level))))
                rank1(i) = level;
            end
            if rank2(i) == 0 && any(contains(txt2, txt(inds(level))))
                rank2(i) = level;
            end
            level = level + 1;
        end
    end
end