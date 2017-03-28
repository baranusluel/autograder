function [r] = f(x, y, k)
m = ((y+k)/17);
a = (-17 .* x - rem((y+k),17));
z = rem(m .* (2 .^(a)),2);
r = floor(z);
end