function [ dist ] = cartDist( x1,y1,x2,y2 )
%cartDist The Distance Formula
%   This function finds the the distance between 2 points in
%   two-dimensional space. 
a = (x2-x1);
b = (y2-y1);
c = a.^2;
d = b.^2;
e = c+d;
dist= sqrt(e);




end

