function [dist1] = cartDist (x1, y1, x2, y2);
dist1 = ((x2-x1).^2 + (y2-y1).^2).^(1/2); 
dist1 = round (dist1, 2); 
end