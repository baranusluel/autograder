function [out1] = f(x,y,k)
%Part 1, the dividend
a = y + k;
%demonimator of Part 1
den = 17;
%Part 1 defined
p1 = floor(a./den);
%Base of exponent
b = 2;
%Part 2 which is the exponential function
%First part of the exponent 
e1 = -17;
e11 = e1.*x
%Second part of the exponent
e2 = rem(a,den);
%exponent as a whole is defined as 
e = e11 - e2;
%Part 2 defined
p2 = b.^e;
%Before we use the floor function, we can call the inside function ins
ins = rem(p1.*p2,2);
out1 = floor(ins);
end











