function [value] = f(x, y, k)
par1 = y + k;
par2 = rem(par1, 17);
par3 = -17 * x - par2;
par4 = 2 ^ par3;
par5 = floor((y+k)/17);
par6 = par4 .* par5;
par7 = rem(par6,2);
[value] = floor(par7);
end