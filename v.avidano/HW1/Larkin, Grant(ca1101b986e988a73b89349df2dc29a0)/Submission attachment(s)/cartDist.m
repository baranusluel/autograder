function [out1] = cartDist(x1,y1,x2,y2) 
% DISTANCE FORMULA IS 2EZ
out1 = roundn(sqrt(((x2-x1).^2) + ((y2-y1).^2)),-2);
end
