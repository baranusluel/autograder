function [out1] = carDist(x1, y1, x2, y2)
out1 = sqrt(((x2 - x1)^2) + ((y2 - y1)^2));
out1 = round(out1, 2);
end