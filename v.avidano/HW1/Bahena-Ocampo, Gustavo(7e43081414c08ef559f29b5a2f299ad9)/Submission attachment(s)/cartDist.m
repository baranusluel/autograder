function out = cartDist(x1,y1,x2,y2)

x = (x2-x1).^2;
y = (y2-y1).^2;
dist = sqrt(x + y);
out = round(dist,2);
end 