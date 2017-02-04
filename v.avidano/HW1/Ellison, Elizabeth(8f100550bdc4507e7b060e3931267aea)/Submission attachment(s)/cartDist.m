function [distance] = cartDist(x1,y1,x2,y2)
param1= (x2)-(x1);
param2= (y2)-(y1);
result= sqrt(((param1)^2)+((param2)^2));
distance=round(result,2);
end 
