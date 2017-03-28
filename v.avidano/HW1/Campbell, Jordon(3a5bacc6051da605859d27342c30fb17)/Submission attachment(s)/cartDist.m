function [distance] = cartDist(x1, x2, y1, y2)

a = (x2 - x1);
b = (y2 - y1);

distance = sqrt((a.^2) + (b.^2));

roundn(distance, -2)








end