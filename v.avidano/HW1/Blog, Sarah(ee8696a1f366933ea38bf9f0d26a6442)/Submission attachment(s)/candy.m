function [ each, waste ] = candy( pieces, kids )
%CANDY given an initial number of pieces and kids, determines how many
%pieces each kid should get and how many will be wasted
each = floor(pieces/kids);
waste = mod(pieces, kids);


end

