function [ distance ] = cartDist( x1, y1, x2, y2 )
% cartDisk calculates the distance between 2 points
%   the points use cartesian coordinates
distance=round(sqrt((x2-x1)^(2)+(y2-y1)^(2)),2);
end

