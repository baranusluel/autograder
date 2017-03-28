function [ xfinal ,vfinal ] = freefall( t )
%freefall- a kinematics program
%   Determines final position and velocity for a free-fallling object.
a=9.807;
x=(a).*(t);
b=(a).*(t.^2);
y=b/2;
vfinal=round(x,3);
xfinal=round(y,3);


end