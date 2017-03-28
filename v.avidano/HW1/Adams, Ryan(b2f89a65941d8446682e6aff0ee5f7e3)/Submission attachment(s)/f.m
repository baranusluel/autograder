function [out] = f(x,y,k)
% Calculate an output based on the given equation
% usage: function [out] = f(x,y,k)
[out] = round(rem(((y+k)/2)*2^(-17*x-rem((y+k),17)),2));
end