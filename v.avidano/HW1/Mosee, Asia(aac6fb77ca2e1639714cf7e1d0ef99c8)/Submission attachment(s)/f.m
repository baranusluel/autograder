function [output] = f(x,y,k)
%
a = rem((y+k),17);
b = 2.^(-17.*x-a);
c=((y+k)./17).*b;
d=2;
output = floor(rem(c,d));

end

