function [dx] = cartDist(x1, y1, x2, y2)
a = x2-x1;
b = y2-y1;
x = sqrt(a .^2 + b .^2);
dx = round(x,2);
end