function out1 = f(x,y,k) 
% a = ((y+k)/17);
% b = -17 * x - mod((y+k),17);
% out1 = (mod(a * 2^b , 2));
a= (y+k);
b= floor (a/17);
c= -17 * x;
d= c - mod (a,17);
out1 = floor (mod(b * 2^d, 2));
end 