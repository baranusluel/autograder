function [output] = f(x,y,k)
output = floor(rem(floor((y+k)/17).*2.^(-17.*x-rem((y+k),17)),2));
end
