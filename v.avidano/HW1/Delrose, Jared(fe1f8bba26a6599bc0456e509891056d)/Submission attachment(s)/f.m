function [soln] = f(x, y, k)
% Following orders of pemdas, begin with creating variable to help evaluate exponents
step1 = rem((y+k),17);
% Next create a variable that encompasses the entire exponent
step2 = -17.*x-step1;
% Create a variable that equals the whole right side of parenthesis
step3 = floor((y+k)./17).*(2.^step2);
% Lastly plug in the last variable to the simplified equation
soln = floor(rem(step3,2));
end