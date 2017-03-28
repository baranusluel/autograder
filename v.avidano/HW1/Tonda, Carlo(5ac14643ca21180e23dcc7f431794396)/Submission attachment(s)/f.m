function [result] = f(x, y, k)
result=floor(rem((floor((y+k)/17))*(2^((-17*x)-rem((y+k),17))),2));%Uses the formula to calculate a ludacris number.
end

