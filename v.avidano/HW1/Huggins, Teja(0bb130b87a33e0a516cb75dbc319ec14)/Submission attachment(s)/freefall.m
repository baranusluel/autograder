function [pos1,veloc1]=freefall(t)
% function will determine the position and velocity of an object free-falling from rest

a=9.807;
pos=(a*(t.^2))./2;
veloc=(a*t);
pos1=roundn(pos,-3)
veloc1=roundn(veloc,-3)
end