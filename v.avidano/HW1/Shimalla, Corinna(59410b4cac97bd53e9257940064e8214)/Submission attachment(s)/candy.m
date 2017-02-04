function [candyKid, waste] = candy(candyBag, kids)
%candyKid = candy per kid
%waste = candy wasted
%candyBag = pieces of candy in bag
candyKid = candyBag ./ kids;
candyKid = floor(candyKid);
waste = candyBag - (candyKid .* kids);
end