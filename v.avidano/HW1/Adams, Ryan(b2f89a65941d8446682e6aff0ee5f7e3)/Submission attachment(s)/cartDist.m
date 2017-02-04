function [out1] = cartDist(x1,y1,x2,y2)
% calculate the cartesian distance between two points
% usage: function [out1] = cartDist(x1,y1,x2,y2)
[out1] = round((sqrt(((x2-x1)^2)+((y2-y1)^2))),2);
end