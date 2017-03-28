function [ p, w ] = candy( c, k )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
w = mod( c, k)

p = floor( c ./ k)


end

