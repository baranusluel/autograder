function [position,velocity] = freefall(t)
% Calculate final position and velocity of a falling object
% usage: function [position,velocity] = freefall(t)
position = round((9.807*(t^2))/2,3);
velocity = round((9.807*t),3);
end