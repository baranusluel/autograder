function [out1,out2] = freefall(t)
a = 9.807;
b = (a * t);
c = (a * t^2);
d = (c/2);
out1 = round (d,3);
out2 = round (b,3);
end 