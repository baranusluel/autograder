function [ dist ] = cartDist( x1, y1, x2, y2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
dx = x2 - x1;
dy = y2 - y1;
sqrdx = dx .^ 2;
sqrdy = dy .^ 2;
initdist = (sqrdx + sqrdy) .^ (1/2);
dist = round(initdist, 2);

end

