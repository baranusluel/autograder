function [out] = f(x,y,k)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% break equation into parts to make sure there's less chance of making a
% mistake
fraction = (y+k)./17;
fractionFloored = floor(fraction);
remainder = rem((y+k),17);
exponent = -17.*x-remainder;
numerator = fractionFloored .* 2.^exponent;
out=floor(rem(numerator,2));


  end

