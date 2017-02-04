function [distance] = cartDist (x1, y1, x2, y2)
xcomponent = (x2 - x1).^2;
ycomponent = (y2 - y1).^2;
squareddistance = xcomponent + ycomponent;
unroundeddistance = sqrt(squareddistance);
distance = (round(unroundeddistance.*100))./100
end