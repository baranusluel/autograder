function [pos, vel] = freefall(time)
% takes 1 input, time in seconds
% returns 2 outputs, the position and velocity of an object in freefall
% released from rest and allowed to fall for that time
g = 9.087;
pos = round(((g/2)*time.^2),3);
vel = round((g*time),3);

end