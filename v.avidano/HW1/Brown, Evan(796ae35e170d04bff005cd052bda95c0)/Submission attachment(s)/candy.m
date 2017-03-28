function [perkid, wasted] = candy (pieces, kids)
perkid = floor(pieces./kids)%rounds down of the remainder so each kid gets the same amount
wasted =mod(pieces, kids)%finds how much wasted based on left overs
end
