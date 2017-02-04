function [pos, vel] = freefall(secs)
a = 9.807;
pos = round(a*secs^2/2,3);
vel = round(a*secs,3);
end