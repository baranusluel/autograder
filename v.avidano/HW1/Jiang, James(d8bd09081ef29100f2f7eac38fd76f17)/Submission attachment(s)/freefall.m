function [posf,velf] = freefall (t)
a = 9.807;
posf = (a*t^2.)/2.;
velf = a * t;
posf = round (posf,3);
velf = round (velf,3);
end
