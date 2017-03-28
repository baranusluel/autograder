function [dist] = cartDist (x1, y1, x2, y2)
%calculate the cartesian distance from P1 to P2
%usage: function [dist] = cartDisp (x1, y1, x2, y2)
dx = x2 - x1;
dy = y2 - y1;
hsq = dx .^ 2 + dy .^2;
dist = sqrt(hsq);
dist = round(dist, 3);
end