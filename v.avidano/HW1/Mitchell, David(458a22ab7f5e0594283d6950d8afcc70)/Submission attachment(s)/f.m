function [ number ] = f( x, y, k )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
num = (rem((y+k),17))
numb = 2.^(-17.*x-num)
numbe = floor(((y+k)./17).*numb)
number = floor(rem(numbe,2));
%completed




end

