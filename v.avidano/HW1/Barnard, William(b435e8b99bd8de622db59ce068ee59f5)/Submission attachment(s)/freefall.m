function [x,v] = freefall(t)
a = 9.807;
x = (a .* t^2)/2;
v = a .* t;
x = round(x,3);
v = round(v,3);
end