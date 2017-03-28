function distance = cartDist (x1,y1,x2,y2)

a = (x2 - x1).^2;
b = (y2 - y1).^2;

distance = sqrt(a + b);
distance = round(distance,2);

end