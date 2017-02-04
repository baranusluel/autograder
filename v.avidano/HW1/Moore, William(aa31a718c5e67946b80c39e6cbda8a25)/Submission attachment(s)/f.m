function [ out1 ] = f( x, y, k )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%a = ((y + k) ./ 17);
%b = 2 .^ (-17.*x - rem((y + k), 17));
%C = a .* b;
%out1 = rem( C, 2);
out1 = rem(((y + k) ./ 17).*(2.^(-17.*x - rem((y+k),17))),2);
end

