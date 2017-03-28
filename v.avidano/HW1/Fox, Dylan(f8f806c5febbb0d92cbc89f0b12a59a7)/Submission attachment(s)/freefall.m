function [ position, velocity ] = freefall( t )
% freefall outputs the final velocity and position 
% of an object given acceleration as time changes
a=9.807;
position=round((a.*t^2)/2,3);
velocity=round(a.*t,3);
end