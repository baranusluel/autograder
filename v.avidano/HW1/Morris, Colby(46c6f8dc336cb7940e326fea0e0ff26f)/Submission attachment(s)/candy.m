function [candyPerKid,candyWasted] = candy(bagSize,numKids)
candyPerKid = bagSize/numKids;
candyPerKid = floor(candyPerKid)
candyWasted = bagSize-(candyPerKid*numKids)
end

