% Paloma Sanchez
% HW 1
%% Function Name: cartDist

% Inputs
% Coordinates (x1,y1) (x2,y2)

% Outputs
% Distance

function [distance] = cartDist(x1,y1,x2,y2)
    distance = round(sqrt((x2-x1).^2 + (y2-y1).^2))
end

