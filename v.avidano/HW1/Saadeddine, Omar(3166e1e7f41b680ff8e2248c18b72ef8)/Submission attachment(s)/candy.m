function [perKid, wasted] = candy(pieces, kids)
perKid = pieces./kids;
perKid = floor(perKid);
wasted = mod(pieces, kids);
end