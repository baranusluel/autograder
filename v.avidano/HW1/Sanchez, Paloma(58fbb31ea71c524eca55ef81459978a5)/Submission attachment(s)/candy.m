% Paloma Sanchez
% HW 1
%% Function Name: candy

% Inputs
% b = number of pieces in the bag
% k = number of kids

% Output
% p = pieces of candy per kid
% w = pieces of candy wasted

function [p,w] = candy(b,k)
    p = floor(b/k)
    w = mod(b,k)
end