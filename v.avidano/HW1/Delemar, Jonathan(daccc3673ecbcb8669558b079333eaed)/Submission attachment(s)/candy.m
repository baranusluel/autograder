function [cpk, cw] = candy(x, y)
cpk = x/y;
cpk = floor(cpk);
cw = x - (cpk*y);
end