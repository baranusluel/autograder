function [kid,left] = candy(k,p)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
%I want to make k the variable for the amount of kids and p the amount of
%candy in the bag
%the output kid is for how many the kids get and left is for what's left in
%the bag
%had to figure out the different notation for floor mod
kid = floor(k./p);
left = mod(k,p);
end
