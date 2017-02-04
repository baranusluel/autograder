function [ distances ] = cartDist(x1, y1, x2, y2)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
distance = sqrt(((x2-x1).^2)+((y2-y1).^2));
distances = round(distance, 2);

%completed
end

