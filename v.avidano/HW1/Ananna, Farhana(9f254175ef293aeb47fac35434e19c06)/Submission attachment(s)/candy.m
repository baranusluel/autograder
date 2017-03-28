function [ out1,out2 ] = candy (x,y)
a=(x/y);
b= mod(x,y);
c=floor(a);
out1=c;
out2 = c-b;
end
%floor rounds to nearest integer

