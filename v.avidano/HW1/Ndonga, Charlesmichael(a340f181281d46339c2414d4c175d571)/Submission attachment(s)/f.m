function[out]=f(x,y,k);
a=y+k;
b=rem(a,17);
c=(a/17);
d=(2.^-17.*x);
out=c.^d;
out=floor(rem(out,2));%
    end