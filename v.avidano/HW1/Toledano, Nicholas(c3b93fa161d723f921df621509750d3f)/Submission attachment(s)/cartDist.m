function [dist] = cartDist(x1,y1,x2,y2)
% The result is the square root of the sumation of the two squared
% differences between each set of points.
    distx = x2-x1;
    disty = y2-y1;
    dist1 = sqrt(distx.^2+disty.^2);
    dist = round(dist1,2);
end