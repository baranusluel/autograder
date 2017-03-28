function [ s,v ] = freefall( t )
%FREEFALL Calculates the position and velocity of an object in freefall for
%   time t
a=9.807;
s=a*t.^2*.5; %finds position using kinematic equation
s=round(s,3);
v=a*t; %finds v
v=round(v,3);
end

