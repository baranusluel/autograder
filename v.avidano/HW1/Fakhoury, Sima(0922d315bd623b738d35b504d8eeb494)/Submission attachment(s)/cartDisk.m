function [dist] = cartDisk (x1, y1, x2, y2)
dist1 = (x2-x1).^2;
dist2 = (y2-y1).^2;
dist3 = sqrt(dist1+dist2);
dist = (round(dist3.*100))./100;
end
