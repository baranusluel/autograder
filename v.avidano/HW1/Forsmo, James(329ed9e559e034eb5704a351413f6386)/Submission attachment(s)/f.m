function [result] = f(x,y,k)
    %computes the result of a complicated math function from inputs x,y,k
    %usage: [result] = f(x,y,k);
    
    %calculate left-hand side of modulus in the function
    lhs = floor((y+k)./17) .* (2.^(17*x-rem((y+k),17)));
    rhs = 2;
    %calculate and return value for result
    result = floor(rem(lhs,rhs));
end

