% Paloma Sanchez
% HW 1
%% Function Name: freefall

% Inputs
% t = time

% Outputs
% p = position
% v = velocity

function [p,v] = freefall(t)
    p = round((9.807*t.^2)/2)
    v = round(9.807*t)
end
