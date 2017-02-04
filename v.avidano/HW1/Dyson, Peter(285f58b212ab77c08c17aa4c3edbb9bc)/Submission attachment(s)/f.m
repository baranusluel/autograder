function [ s ] = f( x, y, k )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

s = round(abs(rem(abs((y+k)/17) .* 2^(-17 .* x - rem((y+k),17)),2)))

end

