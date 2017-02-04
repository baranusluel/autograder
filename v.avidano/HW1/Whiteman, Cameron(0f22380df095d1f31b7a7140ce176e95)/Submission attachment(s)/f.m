function[a]=f(x,y,k)


b=rem((y+k),17);
c=-17.*x;
d=c-b;
f=(y+k)./17;
e=2.^d;
h=e.*f;
a=rem(h,2);
a=floor(a);

end