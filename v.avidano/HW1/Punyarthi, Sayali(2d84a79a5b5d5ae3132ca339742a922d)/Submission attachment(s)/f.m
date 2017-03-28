function [ result1 ] = f (x,y,k)
result1 = floor ( rem ( floor ( (y + k) ./ 17) .* 2.^ (-17 .* x - rem((y+k),17)),2));
end