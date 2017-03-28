function[pieces,wasted]=candy(numPieces,numKids)
pieces = floor(numPieces./numKids); 
wasted = numPieces-numKids.* pieces;
end