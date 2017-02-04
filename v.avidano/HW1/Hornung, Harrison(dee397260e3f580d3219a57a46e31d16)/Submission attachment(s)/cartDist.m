function answer = cartDist(x1,y1,x2,y2)
% CartDist solver
% Uses points = (x1,x2,y1,y2) to calculate distance between point (x1,y1) and
% point (x2,y2)

dx = x1-x2;
% defines distance x
dy = y1-y2;
% defines distance y
distsqr = dx .^2 + dy .^2;
% squares and adds together each distance
distsqrt = sqrt(distsqr);
% produces distance measurement
answer = round(distsqrt,2);
% rounds answer to the nearest hundreth

end



