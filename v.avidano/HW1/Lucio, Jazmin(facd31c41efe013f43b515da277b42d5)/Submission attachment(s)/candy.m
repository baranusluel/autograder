function [perKid, wasted] = candy(inbag, kids)
perKid = inbag/ kids;
wasted = mod(inbag,kids);
round(perKid);
end
