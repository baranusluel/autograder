function [ dist ] = cartDist(x_1,y_1,x_2,y_2)
XX = (x_2 - x_1);
YY = (y_2 - y_1);
dist = sqrt((XX.^2)+(YY.^2));
N = -2;
round(dist, N);
end


