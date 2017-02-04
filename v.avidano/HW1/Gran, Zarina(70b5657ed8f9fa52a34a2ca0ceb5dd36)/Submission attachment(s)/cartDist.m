function [dist] = cartDist(x1, y1, x2, y2)
%Difference between the 2 x values
x_diff = x2 - x1; 
%Difference between the 2 y values
y_diff = y2 - y1;
%The difference between x values, squared
xs = x_diff.^2;
%The difference between y values, squared
ys = y_diff.^2;
%Radicand
r = xs + ys;
%Before rounding
dist1 = sqrt(r);
dist = round(dist1,2)
end




