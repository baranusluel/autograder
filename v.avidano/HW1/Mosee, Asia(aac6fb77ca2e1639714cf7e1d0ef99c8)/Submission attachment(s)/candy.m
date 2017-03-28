function [perkid,wasted]=candy(candy,kids)
a=candy./kids;
perkid=floor(a);
wasted=mod(candy,kids);

end
