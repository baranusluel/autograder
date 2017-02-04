function [ y1, y2 ] = candy(x1, x2)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
    %x1 = number of pieces of candy in a bag 
    %x2 - number of kids 
    %y1 = pieces of candy per kid
    %y2 = pieces of candy wasted 

    y1 = floor(x1./x2);
    y2 = rem(x1,x2);
    
end

