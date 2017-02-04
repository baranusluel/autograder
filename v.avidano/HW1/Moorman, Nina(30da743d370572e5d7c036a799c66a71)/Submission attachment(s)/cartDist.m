function output1 = cartDist (x1, y1, x2, y2)
% parenthesis 1
parenthesis_1 = ((x2 - x1) .^2); 
% parenthesis 2
parenthesis_2 = ((y2 - y1) .^2);
% left rounded
left_rounded = sqrt ( parenthesis_1 + parenthesis_2);
% output 1
output1 = round (left_rounded, 2);
end