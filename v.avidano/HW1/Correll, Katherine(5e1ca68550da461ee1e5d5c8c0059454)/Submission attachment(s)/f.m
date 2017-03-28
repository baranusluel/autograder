function [value] = f(x, y, k)
a = ((y+k)./17);
b = (-17.*x-rem((y+k),17));
c = 2.^(b);
d = a.*c;
value = floor(rem(d, 2))
end