function [ distance ] = cartDist( x1, y1, x2, y2 )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

x = (x2 - x1)^2;

y = (y2 - y1)^2;

distance = round(sqrt(x + y),2);


end

