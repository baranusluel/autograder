function [out1] = f ( x,y,k )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
exp = -17 .*x - rem((y + k),17);
frac = floor((y + k) ./ 17);
in1 = frac .* 2.^exp;
[out1] = floor(rem(in1,2));
end

