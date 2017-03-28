function [candykid,candywaste] = candy (pieces,numkid)
candykid = floor(pieces./numkid);
%calculates the number of pieces of candy given to each kid
candywaste = pieces -(candykid.*numkid);
%calculates the waste by taking the total pieces minus the number given to
%the kids
end