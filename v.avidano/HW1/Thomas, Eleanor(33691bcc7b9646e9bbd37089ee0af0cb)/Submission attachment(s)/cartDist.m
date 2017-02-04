function [distance] = cartDist(x1, y1, x2, y2)
%distance formula
a = (x2-x1) ;
b = (y2-y1) ;
c = (a.^2) + (b.^2) ;
distance = sqrt(c) ;
end