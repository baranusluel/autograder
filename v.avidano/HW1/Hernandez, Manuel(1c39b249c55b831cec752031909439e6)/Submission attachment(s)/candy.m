function [ perKid , wasted ] = candy ( numcandy , numkid )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
pieces = numcandy ./ numkid;
perKid = floor ( pieces );
wasted = mod ( numcandy , numkid); 

end

