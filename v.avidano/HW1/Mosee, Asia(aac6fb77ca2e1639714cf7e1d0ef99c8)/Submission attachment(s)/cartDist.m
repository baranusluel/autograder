function distance=cartDist(x1,y1,x2,y2)
a=x2-x1;
b=y2-y1;
c=a.^2 + b.^2;
distance=sqrt(c);
distance=roundn(distance,-2);

end
