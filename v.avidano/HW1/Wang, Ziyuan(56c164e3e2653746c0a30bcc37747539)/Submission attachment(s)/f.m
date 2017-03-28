function [out] = f(x,y,k)
var1 = -17.*x-rem((y+k),17);
var2 = floor((y+k)/17).*power(2,var1);
[out] = floor(rem(var2,2));
end