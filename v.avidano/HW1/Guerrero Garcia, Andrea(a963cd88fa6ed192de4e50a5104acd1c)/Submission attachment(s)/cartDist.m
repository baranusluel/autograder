function [dist] = cartDist(x1,y1,x2,y2)
xcomp = x2-x1
ycomp = y2-y1
distance = xcomp.^2 + ycomp.^2
dist=distance.^(1/2)
end 
