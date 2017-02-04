function [dist] = cartDist(x1,y1,x2,y2)
% first create 2 variables for the differences in points
x = (x2-x1);
y= (y2-y1);
% plug into equation and solve
dist = round(((x.^2)+(y.^2)).^0.5,2);