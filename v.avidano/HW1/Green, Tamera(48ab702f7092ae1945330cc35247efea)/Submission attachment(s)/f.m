function [out] = f(x, y, k)
exp = -17 .* x - rem((y + k),17);
frac = floor((y + k) ./ 17);
int1 = frac .* 2 .^ exp;
out = floor(rem(int1, 2));
end
