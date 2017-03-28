function result = f(x,y,k)
a = y+k;
b = -17*x-rem(a,17);
result = floor(rem(a/17*2^b,2));
end