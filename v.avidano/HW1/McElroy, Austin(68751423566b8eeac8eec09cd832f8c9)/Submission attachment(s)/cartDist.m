function dist = cartDist(x1,y1,x2,y2)
xs = (x2-x1)^2;
ys = (y2-y1)^2;
dist = round(sqrt(xs+ys),2);
end