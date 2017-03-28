function output = f (x, y, k)
% sum
sum = y + k; 
% exponent
exponent = -17.*x-rem(sum,17);
% two_up
two_up = 2.^exponent;
% fraction
fraction = sum/17;
% left
left = fraction.*two_up;
% together
together = rem (left, 2);
% output
output = floor (together);
end