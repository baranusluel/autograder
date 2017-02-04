function [out1] = f(x, y, k)
par1 = y+k;
par2 = rem(par1, 17);
par3 = -17*x-par2;
par4 = 2 ^ par3;
par5 = floor((par1)/17);
par6 = par5*par4;
par7 = rem(par6, 2);
out1 = floor(par7);
end
%Test Cases
% [out1] = f(2, 3, 4)
% out1 = 0
%
%[out1] = f(0, 3, 1292)
% out1 =1