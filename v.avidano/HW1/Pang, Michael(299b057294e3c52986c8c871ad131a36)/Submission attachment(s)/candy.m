function [candyPer, candyW] = candy(candyBag, k)
candyPerRem = candyBag/k;
[candyPer] = floor(candyPerRem);
[candyW] = mod(candyBag, k);
end