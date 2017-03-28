%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function Description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: candy
%%
%Inputs:
%1. (double) Number of pieces of candy in a bag
%2. (double) Number of kids

%Outputs:
%1. (double) Pieces of candy per kid
%2. (double) Pieces of candy wasted

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%You are at a birthday party and buy a bag of candy to hand out to each of the kids who
%attend. But in order to be fair, every kid has to get the same number of pieces, and any pieces
%left over in the bag are considered to be wasted.

%This function will take in the number of pieces of candy in a given bag and determine
%how many pieces of candy each kid gets, and how many pieces of candy are wasted. 

%For example, if the size of the bag was 50 pieces, and there were 4 kids at the party, each kid would
%get 12 pieces of candy and 2 pieces of candy would be wasted. So the first output would be 12
%and the second would be 2.

%You may find the floor() and/or mod() functions useful.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function[perKid1, wasted1] = candy(candy1, kids1)
perKid1 = (floor(candy1./kids1));
wasted1 = (candy1 - (kids1.*perKid1));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [perKid1, wasted1] = candy(300, 12)
% 	perKid1 => 25
% 	wasted1 => 0
%Status: PASSED
% 
% [perKid2, wasted2] = candy(34, 13)
% 	perKid2 => 2
% 	wasted2 => 8
%Status: PASSED
% 
% [perKid3, wasted3] = candy(100, 10)
% 	perKid3 => 10
% 	wasted3 => 0
%Status: PASSED

%COMPLETED 