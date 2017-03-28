function [candyKid candyWaste] = candy(candyBag,numKids)

%This divides the candy among the kids, but includes a decimal
candyDecimal = candyBag./numKids;

%This floors candyDecimal, giving the most amount of candy per child
candyKid = floor(candyDecimal);

%Finds the remainder of candies after candy is distributed
candyWaste = mod(candyBag, candyKid);
end

