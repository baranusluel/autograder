function dist = cartDist(x1,y1,x2,y2)
xdist = (x2-x1).^2;
ydist = (y2-y1).^2;
dist = round(sqrt(xdist+ydist),2);
end