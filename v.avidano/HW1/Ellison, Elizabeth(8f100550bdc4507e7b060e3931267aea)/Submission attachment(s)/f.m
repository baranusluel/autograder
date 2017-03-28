function [value] = f(x,y,k)
a=((y+k)./17);
b=(2.^((-17.*x)-rem((y+k),17)));
c=a.*b;
value=floor(rem(c,2));
end