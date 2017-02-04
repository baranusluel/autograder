function [distance] = cartDist(x1,y1,x2,y2)
a = sqrt((x2 - x1)^2 + (y2 - y1)^2);
distance = round(a,2);
end