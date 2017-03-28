function [fpos, fvel] = freefall(time)
% create constant of accel
acc = 9.807;
% Plug into equation for position
fpos = round(((acc .* (time .^2))./ 2),3);
% Plug into equation for velocity
fvel = round((acc .* time),3);