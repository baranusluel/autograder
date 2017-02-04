function [result] = f (x, y, k)
first = rem((y+k),17);
second = 2.^((-17 * x) - first);
third = ((y+k)/17);
fourth = third * second;
result1 = rem(fourth,2);
result = floor(result1);
end