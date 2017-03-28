function [ p, v ] = freefall( t )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
pf = (9.807 * t .^ 2) ./ 2;
vf = 9.807 * t;
p = round(pf, 3)
v = round(vf, 3)


end

