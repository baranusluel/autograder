function [double] = f (x,y,k)
%function header with an output called double
a = rem((y+k),17);
%takes the remainder of (y+k) and 17
b = -17.*x;
%first part of the exponent in the function description
c = 2.^(b-a);
%two raised to the exponent in the function description
d = floor((y+k)./17);
%rounds (y+k) divided by 17 down to the closest integer
e = rem(d.*c,2);
%e is the inside portion of the function description excluding the floor
double = floor(e);
%the final output is obtained by rounding e down to the closest integer
end