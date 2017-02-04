function [output1, output2] = candy(pieces, kids) 
output1 = floor(pieces/kids) ;
output2 = mod(pieces, kids) ;
end