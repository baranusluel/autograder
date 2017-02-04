function [perKid,wasted]=candy(candyBag,kids)
perKidDec=candyBag./kids;
perKid=floor(perKidDec);
wasted=candyBag-(kids.*perKid);
end




