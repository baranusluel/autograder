function [candyKid, candyWasted] = candy(numPieces, numKids)
candyKid = numPieces/numKids;
candyKid = floor(candyKid);

candyWasted = mod(numPieces,numKids);

end

