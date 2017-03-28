function [out1] = f(x,y,k)
%to ensure order of operations var1 is created
var1 = (-17 .* x);
%var3 is used throughout since y+k is used throughout
var3 = (y + k);
%var3 is used to find the second half of the exponent
varA = rem(var3,17);
%var2 combines var1 and varA in the exponent
var2 = 2 .^(var1 - varA);
%var4 solves the inside of the floor function
var4 = var3 ./ 17;
%taking the floor:
var5 = floor(var4);
%multiplying the two parts within the rem together:
var6 = var5 .* var2;
%taking the rem:
var7 = rem(var6,2);
%taking the floor of the whole thing
out1 = floor(var7);
end 
