function [x,y] = candy(a,b)
% Child candy allotment solver
% This function calculates the amount of candy each child should be given
% and how much candy is left over or "wasted".
%
% a = number of pieces of candy in a bag
% b = number of kids
%
% x = pieces of candy per kid
% y = pieces of candy wasted

y = mod(a,b);
x = floor(a./b);

end



