function [out] = f(x,y,k)
% takes three inputs: x, y, k, doubles
% returns one output: out, double
a = rem((y+k),17);
b = 2.^((-17*x)-a);
c = floor((y+k)/17);
d = rem((b*c),2);
out = floor(d);

end