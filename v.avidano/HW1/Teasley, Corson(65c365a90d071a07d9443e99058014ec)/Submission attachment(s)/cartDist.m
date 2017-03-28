function [out] = cartdist (firstx, firsty, secondx, secondy)
%out equals distance btwn two points

out = round( sqrt ( (secondx - firstx)^2 + (secondy - firsty)^2), 2);


end