function [posrd, velrd] = freefall (t)
a = 9.807;
pos = (a * (t^2))/2;
posrd = round(pos,3);
vel = a * t;
velrd = round(vel,3);
end