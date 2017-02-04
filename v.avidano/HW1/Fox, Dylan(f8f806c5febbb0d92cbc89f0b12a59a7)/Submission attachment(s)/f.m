function [ result1 ] = f( x,y,k )
% f outputs the result of inputing the values 
% for x, y, and k into the equation
exponent=(-17*x)-rem((y+k),17);
fraction=(y+k)/17;
result1=floor(rem(floor(fraction)*2^exponent,2));
end

