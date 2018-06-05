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
