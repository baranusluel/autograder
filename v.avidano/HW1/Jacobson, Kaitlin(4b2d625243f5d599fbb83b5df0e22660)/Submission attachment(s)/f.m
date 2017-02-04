function [out1] = f(x, y, k)
par1 = y + k; 
par2 = rem(par1, 17); %find remainder of the division of par1 by 17
par3 = -17 .* x - par2;
par4 = 2 .^ par3;
par5 = floor((y+k)./17); %round the answer down to nearest integer
par6 = par5 .* par4;
par7 = rem(par6, 2); %find remainder of the division of par6 by 2
out1 = floor(par7); %round the answer down to nearest integer
end