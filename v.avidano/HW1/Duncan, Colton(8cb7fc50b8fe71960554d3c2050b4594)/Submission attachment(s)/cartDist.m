function distance=cartDist(x1,y1,x2,y2)
x=(x1-x2).^2;
y=(y1-y2).^2;
sum=x+y;
distance=roundn(sqrt(sum),-2);

end