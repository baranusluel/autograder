function [outt] = f(x,y,k)
exp = -17.*x - rem((y + k),17);
frac = floor((y + k) ./ 17);
in1 = frac .* 2.^exp;
outt = floor(rem(in1, 2));
end