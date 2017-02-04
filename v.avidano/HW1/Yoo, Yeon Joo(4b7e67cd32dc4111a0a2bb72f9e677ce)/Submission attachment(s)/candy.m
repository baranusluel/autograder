function [ k, w ] = candy( numCandy, numKids )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
k=floor(numCandy/numKids);
w=mod(numCandy,numKids);


end

