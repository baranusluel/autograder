function [perKid, wasted] = candy(numBag, numKids) 
perKid = numBag ./ numKids;
perKid = floor(perKid);
wasted = mod(numBag, numKids);
end




