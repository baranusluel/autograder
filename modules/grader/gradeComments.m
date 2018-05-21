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
% * The number of those comments that appears in the dictionary
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
