function [value] = f(x,y,k)

value = floor(rem( ((y+k)/17)*2^((-17*x)-rem( (y+k),17)),2));
end


