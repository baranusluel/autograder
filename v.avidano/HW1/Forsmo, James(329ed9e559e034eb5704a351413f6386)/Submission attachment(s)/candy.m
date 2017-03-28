function [ candyPerKid, candyWasted ] = candy( numCandy, numKids )
    %takes a given number of candies and kids, and then divides 
    %the candy equally among kids | returns number of candies per kid and
    %number of candies left-over (wasted)
    
    %calculate candies per kid
    candyPerKid = floor(numCandy ./ numKids);
    
    %calculate candies wasted (left-over)
    candyWasted = mod(numCandy,numKids);
end

