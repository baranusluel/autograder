function [perKid, candyWasted] = candy(perBag, numKids)
    perKid = floor(perBag./numKids);
    candyWasted = mod(perBag,numKids);
end