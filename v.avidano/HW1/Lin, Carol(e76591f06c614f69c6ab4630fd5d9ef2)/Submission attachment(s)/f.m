function result = f(x,y,k)

a = (y+k)/17;
ex = -17*x-rem((y+k),17);

result = rem(a*2.^ex, 2);

result = floor(result);

end