% Paloma Sanchez
% HW 1
%% Function Name: f

function [output] = f(x,y,k)
    output = floor([rem([y+k/17]*2.^(-17*x-rem((y+k),17)),2)])
end

