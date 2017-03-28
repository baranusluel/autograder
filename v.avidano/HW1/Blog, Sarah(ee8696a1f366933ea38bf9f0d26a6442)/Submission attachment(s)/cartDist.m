function [ d ] = cartDist( x1, y1, x2, y2 )
%CARTDIST calculates the distance between two points on a cartesian frame
d=((x1-x2).^2 + (y1-y2).^2).^.5;
d=round(d,2);
end

