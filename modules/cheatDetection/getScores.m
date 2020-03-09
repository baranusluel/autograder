%% getScores: Score a student against the class
%
% getScores scores cheat probabilities against the class
%
% S = getScores(I) will use student index I to generate scores S.
%
% getScores([], T) will store T to be used when the former call is made.
%
%%% Remarks
%
% getScores returns a cell array that is the same size as the number of
% students. Each entry is a vector of 1xP, where P is the number of
% problems. That vector represents the confidence that the input student I
% cheated on problem number P with student C, where C is the given index in
% the output.
function scores = getScores(s1, studs)
    % Minimum number of code lines before we start checking for cheating
    MIN_LINES = 7;
    persistent students;
    if nargin == 2
        students = studs;
        return;
    end
    subs = students{s1};
    % students is cell array; each cell is a cell array of size p, and each
    % entry there is the contents of a single problem and its hash
    
    % for each student, for each problem, calculate the jaccard index
    scores = cell(1, numel(students));
    for s2 = 1:numel(scores)
        txts = students{s2};
        if s1 == s2
            scores{s2} = zeros(1, numel(txts));
        else
            for p = numel(txts):-1:1
                % get jaccard index
                if subs{p}{3} >= MIN_LINES && txts{p}{3} >= MIN_LINES
                    % compare
                    if subs{p}{2} == txts{p}{2}
                        scores{s2}(p) = Inf;
                    else
                        [rank1, rank2] = jaccardIndex(subs{p}{1}, txts{p}{1});
                        scores{s2}(p) = sum(rank1 == rank2) / length(rank1);
                    end
                else
                    scores{s2}(p) = 0;
                end
            end
        end
    end
end