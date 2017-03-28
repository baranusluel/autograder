function [ dist ] = cartDist( x1,y1,x2,y2 )
    %computes the distance between two points using pythagorean theorem
    %inputs x1,y1,x2,y2 are components of the coordinates of points 1 and 2
    
    %calculate displacements for x and y axes
    dispX = x2 - x1;
    dispY = y2 - y1;
    
    %calculate and return distance
    dist = sqrt((dispX.^2)+(dispY.^2));
end

