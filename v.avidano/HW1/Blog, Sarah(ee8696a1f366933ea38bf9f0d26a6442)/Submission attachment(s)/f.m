function [ r ] = f( x,y,k )
%F Finds the output of the equation in the first part of Homework 1
a = y+k; %simplies where rhs term is repeated in the function
r= floor(a/17);
b= -17.*x-rem(a,17);
r= r.* 2.^b;
r= rem(r,2);
r=floor(r);
end

