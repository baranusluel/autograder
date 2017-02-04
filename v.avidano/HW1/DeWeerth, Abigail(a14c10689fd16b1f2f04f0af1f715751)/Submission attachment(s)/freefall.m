function [ pos, v ] = freefall( time )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
a = 9.807;
sqr = time .^ 2;
pos = round(((a .* sqr) / 2) , 3);
v = round((a .* time) , 3);

end

