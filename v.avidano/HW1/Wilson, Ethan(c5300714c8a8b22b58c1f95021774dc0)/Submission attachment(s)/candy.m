function [perkid, wasted] = candy(numcandy, numkids)
perkid = floor(numcandy/numkids);
wasted = mod(numcandy, numkids);
end
