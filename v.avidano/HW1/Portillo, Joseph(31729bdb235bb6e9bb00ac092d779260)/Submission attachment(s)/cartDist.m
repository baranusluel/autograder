function [dist] = cartDist(x1,y1,x2,y2)
% takes 4 inputs that represents two rectangular coordinates in 2D space
% returns 1 output, the straight-line distance between the points

a = sqrt((x2 - x1).^2 + (y2 - y1).^2);
dist = round(a,2);

end