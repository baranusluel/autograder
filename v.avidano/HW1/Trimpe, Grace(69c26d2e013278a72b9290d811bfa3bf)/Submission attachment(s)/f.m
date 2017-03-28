function [res] = f(x,y,k)
%break down the equation into smalls parts to solve
%put in three imputs for all teh variables and only one output
%usage: function [res] = f(x,y,k)
var1 = y+k;
var2 = var1/17; 
var3 = -17 .* x;
var4 = 2^(var3-rem(var1,17));
var5 = floor(var2);
var6 = rem((var5 * var4),2);
%broke the equation down into small parts that build on each other
res = floor(var6);
%I left the rem and floor part until the end but used the varibales to
%simplify the equation

end