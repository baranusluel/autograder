function [dist] = cartDist(x1 , y1 , x2 , y2)
%Calculates the distance between two points in a two dimensional cartesian
%plane

dist = sqrt((x1 - x2).^ 2 + (y1 - y2).^ 2);

end