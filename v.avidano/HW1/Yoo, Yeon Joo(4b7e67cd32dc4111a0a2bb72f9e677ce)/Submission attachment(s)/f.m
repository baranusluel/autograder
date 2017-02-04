function [ out ] = f( x, y, k )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
out=floor(rem(floor((y+k) ./17) .*2^(-17.*x-rem((y+k),17)),2));


end

