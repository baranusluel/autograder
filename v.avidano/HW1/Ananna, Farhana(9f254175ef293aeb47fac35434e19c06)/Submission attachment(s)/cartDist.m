function out1 = cartDist(x1,y1,x2,y2)
a= (x2-x1)^2;
b= (y2-y1)^2;
c= sqrt(a+b);
out1 = round(c,2);
end
