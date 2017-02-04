function [cc, cw] = candy(c,k)
a = c/k;
cc = floor(a);
g = k .* cc;
cw = c - g;
end