function [ pKids, wasted ] = candy( pieces, nKids )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

wasted = mod(pieces , nKids);

pKids = (pieces - wasted)/ nKids;



end

