function [perkid,wasted] = candy(bag,kids)




perkid = bag/kids - rem(bag,kids)

wasted = rem(bag,kids)







end