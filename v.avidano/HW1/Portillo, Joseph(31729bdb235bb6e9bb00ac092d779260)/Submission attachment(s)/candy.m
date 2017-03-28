function [candy_perKid, numWasted] = candy(candy_inBag, numKids)
% takes 2 inputs: the amount of candy in a bag, and the number of kids at
% the party.
% returns 2 outputs: the amount of candy each kid gets, and the number of
% pieces wasted.
candy_perKid = floor(candy_inBag/numKids);
numWasted = mod(candy_inBag, numKids);

end