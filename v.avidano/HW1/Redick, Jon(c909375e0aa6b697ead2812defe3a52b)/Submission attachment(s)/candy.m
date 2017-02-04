function [ perkid,wasted ] = candy( candies,kids )
%candy- dividing candy evenly among kids
%   This function will ensure fairness by showing how many of pieces each
%   child should get, as well as showing how many pieces are wasted.

perkid=floor((candies)./(kids));
wasted=mod((candies),(kids));


end

