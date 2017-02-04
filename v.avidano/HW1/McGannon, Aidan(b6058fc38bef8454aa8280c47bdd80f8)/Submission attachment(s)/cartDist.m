function [ dist ] = cartDist( x1, y1, x2, y2 )
%   Calculate the distance from p1 to p2
%   usage: function [dist] = cartdist
dx = x2 - x1;
dy = y2 - y1;
hsq = (dx .^ 2) + (dy .^2);
dist = sqrt(hsq);
dist = round(dist,2);
end

