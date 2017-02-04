function [ candynum, waste ] = candy( pieces, kids )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
candynum = floor(pieces ./ kids);
waste = rem(pieces, kids);

end

