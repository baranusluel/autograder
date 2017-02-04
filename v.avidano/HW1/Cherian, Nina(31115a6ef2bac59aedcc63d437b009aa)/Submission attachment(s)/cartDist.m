function [ dist ] = cartDist( x1, y1, x2, y2 )
%calculate the cartesian distance from P1 to P2
%   usage: function[ dist ] = cartDist( x1, y1, x2, y2 )
    dx = x2-x1; %dx=change in x
    dy = y2-y1; %dy=change in y
    hsq = dx .^2 + dy .^2;
    dist = sqrt(hsq); 
    dist = round (dist.* 100)./100;  %I chose to use this function because I round the number when I multiply by 100 and then divide by 100 again to get a rounded decimal. 
    

end

