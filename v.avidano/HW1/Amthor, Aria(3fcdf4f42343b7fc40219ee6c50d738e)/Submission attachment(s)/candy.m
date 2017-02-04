%takes the numberof pieces of candy in a bag and the number of kids
%to determine how many pieces of candy per kid and how much candy
%is wasted

function [pieces, waste] = candy(bag, kids)
    %finds the number of pieces per kid, exactly
    divide = bag ./ kids;
    
    %finds the number of pieces per kid, rounded down to be practical
    pieces = floor(divide);
    
    %finds how much candy is wasted by not being given to a kid
    waste = mod(bag, kids);
end
