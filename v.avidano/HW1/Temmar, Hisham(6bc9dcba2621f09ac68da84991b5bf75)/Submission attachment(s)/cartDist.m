%This Function Finds the distance between two points on the cartesian plane
function [dist] = cartDist(x1,y1,x2,y2)

% This subtracts x1 from x2
a = x1-x2;

% This subtracts y1 from y2

b = y1-y2;

% This squares both a and b
sqa = a.^2;
sqb = b.^2;

% This adds the squares of a and b
totsq = sqa+sqb;

% This takes the square root of totsq
tot = totsq.^(1/2);

%This rounds the distance to the nearest hundredth
dist = roundn(tot,-2);
end
