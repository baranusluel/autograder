function [dist] = cartDist(x1, y1, x2, y2)
deltaX = x2 - x1;
deltaXsq = deltaX^2;
deltaY = y2 - y1;
deltaYsq = deltaY^2;
sum1 = deltaXsq + deltaYsq;
[dist] = sqrt(sum1);
end