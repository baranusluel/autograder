function [ dist ] = cartDist( x1, y1, x2, y2 )

horz = x2 - x1;
vert = y2 - y1;
dist= sqrt(horz.^2 + vert.^2);
dist = round(dist, 2);


end

