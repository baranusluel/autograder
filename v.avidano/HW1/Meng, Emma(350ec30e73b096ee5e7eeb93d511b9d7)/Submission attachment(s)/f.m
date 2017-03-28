function [charles] = f(x,y,k)
%Input functions for x,y,z to evaluate function
charles = [rem([(y+k)/17]*2^(-17*x-rem((y+k),17)),2)];
%Round down value
charles = floor(charles);

end