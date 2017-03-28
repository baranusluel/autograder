function [ pf, vf ] = freefall( s )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

a = 9.807;

pf = round((a .* s^2) / 2, 3);

vf = round(a .* s, 3);

end

