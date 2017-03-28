function [out] = cartDist (x1 , y1 , x2 , y2)
xDist = x2-x1
yDist = y2-y1
lnDist = sqrt(xDist.^2+yDist.^2)
[out] = round(lnDist,2)
end