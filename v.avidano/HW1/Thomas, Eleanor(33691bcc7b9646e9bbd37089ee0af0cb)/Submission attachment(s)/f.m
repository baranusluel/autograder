function [answer] = f(x,y,k)
%breaking the function up into bits
a = (y+k) ;
b = (a./17) ;
c = (-17.*x) ;
d = (rem(a,17)) ;
e = c-d ;
%put it all back together
answer = rem((b .* 2 .^ e),2) ;
end
