function[distance] = cartDist(x1,y1,x2,y2)
x=x1-x2;
y=y2-y1;
x=x.^2;
y=y.^2;
sum=x+y;
a=sqrt(sum);
distance=round(a,2);
end
