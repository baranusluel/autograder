function [fred] = f( x,y,k )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fred = x + y + k;

exp=(-17*x)-rem((y+k),17) %to define exponent
fred = floor(rem(((y+k)/17)*2^exp,2))
% 	out1 => 0
% 
% [out1] = f(0, 3, 1292)
% 	out1 => 1

end


