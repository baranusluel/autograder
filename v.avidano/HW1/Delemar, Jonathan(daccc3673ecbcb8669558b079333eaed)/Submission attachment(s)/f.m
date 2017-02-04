function [out] = f(x, y, k)
out = floor(rem(floor((y+k)/17) * 2^(-17*x-rem((y+k), 17)), 2));
end