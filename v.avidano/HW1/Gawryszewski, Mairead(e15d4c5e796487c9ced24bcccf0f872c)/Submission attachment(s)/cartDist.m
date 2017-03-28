function [cartDist] = cartDist(x1, y1, x2, y2)

% how to apply round function? 
% is 3.4300 okay?
% is currently saying it exceeds matrix dimensions- clear and clc
x = (x2 - x1);
y = (y2 - y1);
hypsq = (x .^2) + (y .^2);
cartDist = sqrt(hypsq);


end