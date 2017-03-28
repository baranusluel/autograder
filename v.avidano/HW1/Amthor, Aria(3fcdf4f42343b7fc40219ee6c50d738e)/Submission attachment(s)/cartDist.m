%takes the coordinates of two points in 
%2D space and calculates the distance 
%between them

function [dist] = cartDist(x1,y1,x2,y2)
    %calculates x and y distances
    dx = x2 - x1;
    dy = y2 - y1;
    
    %calculates the exact distance between points
    distfull = sqrt((dx .^ 2) + (dy .^ 2));
    
    %rounds the distance to the nearest hundredth
    dist = roundn(distfull, -2);
    end
