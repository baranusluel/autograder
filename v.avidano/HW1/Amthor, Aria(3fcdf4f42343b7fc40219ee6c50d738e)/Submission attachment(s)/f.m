%evaluates a mathematic function using 3 inputs

function [result] = f(x,y,k)
    %calculates the remainder after dividing a sum by 17
    remainder = rem((y + k), 17);
    
    %raises 2 to a power calculated using the input "x" and "remainder"
    exponent = 2 .^ (-17 .* x - remainder);
    
    %finds the floor of an expression using "y" and "k"
    floor1 = floor((y + k) ./ 17);
    
    %multiplies the floor with the exponentiated number
    mult = floor1 .* exponent;
    
    %finds the remainder of the previous answer when divided by 2
    rem2 = rem(mult, 2);
    
    %the final result, calculated by taking the floor of rem2
    result = floor(rem2);
end
