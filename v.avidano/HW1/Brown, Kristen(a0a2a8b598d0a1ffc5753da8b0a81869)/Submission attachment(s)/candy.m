function [numCanD numWst]=candy(numBag, numKid)
numCanD=floor(numBag./numKid);
numWst=mod(numBag,numKid);
end