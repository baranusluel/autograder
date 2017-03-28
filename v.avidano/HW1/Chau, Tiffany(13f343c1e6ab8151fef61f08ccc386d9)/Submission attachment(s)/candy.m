function [perKid, waste] = candy(numCandy, numKids)
%this function calculates the pieces of candy per kid
%and the pieces wasted based on the number of pieces of 
%candy in a bag and the number of kids present. 
%the floor function rounds down to ensure we don't have 
%fraction of a piece of candy per kid. the mod function
%gives the remainder after the candy is divide per kid. 
  var numCandy;
  var numKids;
  perKid=floor((numCandy/numKids));
  waste=mod(numCandy, numKids);
end