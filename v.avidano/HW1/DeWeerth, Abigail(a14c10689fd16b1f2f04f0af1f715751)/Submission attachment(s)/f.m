function [ res ] = f( x, y, k )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
a = y + k;
b = floor( a ./ 17 );
expo = -17 .* x - rem(a,17);
power = 2 .^ expo;
res = floor(rem(b .* power , 2));

end

