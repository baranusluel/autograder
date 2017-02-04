function [pieces, wasted] = candy(bagSize, numKids)
pieces = floor(bagSize ./ numKids);
wasted = mod(bagSize, numKids);
end