function [ out2 ] = cartDist( x1,y1,x2,y2 )
%Cartesian Distance between 2 points
 
% function will take in two points defined in 2 dimensional space and
% calculate the distance between them

dx=x2-x1;
dy=y2-y1;
hypsq=dx.^2+dy.^2;
dist=sqrt(hypsq);
out2=roundn(dist,-2);

end

