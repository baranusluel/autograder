function [out1] = cartDist(x1,y1,x2,y2)

distx = x2-x1;
disty = y2-y1;
out1 = sqrt(distx.^2+disty.^2);
out1 = round(out1,2);

end