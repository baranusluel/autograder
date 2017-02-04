function [distance] = cartDist(x1, y1, x2, y2)
%this function finds the cartesian distance
%between two specified points in the x-y plane
%var a is the distance between the x points
%var b is the distance between the y points
%var c finds the square root of a and b 
%the output distance is then rounded to a certain #
%of decimal points 
    var a;
    var b; 
    var c; 
    a=(x2-x1)^2;
    b=(y2-y1)^2;
    c=sqrt(a+b);
    distance=roundn(c,-2);
end