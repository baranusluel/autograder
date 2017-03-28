function [ P, W ] = candy( c, k )
%This function will divide up the candy from a bag evenly among a group of
%children. The function will be able to determine how much candy would be
%left over when each child receives the same amount of candy. 
%   usage: function [ candy ] = candy( c, k )
    W = rem(c, k);  %W is the variable used for the number of candies wasted
    P= floor(c ./ k);  % P is the number of Pieces of candy received by the Kids
    

end

