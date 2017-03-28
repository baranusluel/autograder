function [out1] = cartDist (x1,y1,x2,y2)
a = x2-x1;
%determines the change in the x position
b = y2-y1;
%determines the change in the y position
c = a.^2;
%squares the change in x position
d = b.^2;
%squares the change in y position
e = c+d;
%adds the squares of the x and y position
f = e.^(.5);
%takes the square root of the sum of the squares
out1 = round(f,2);
%outputs the distance between the two points
end