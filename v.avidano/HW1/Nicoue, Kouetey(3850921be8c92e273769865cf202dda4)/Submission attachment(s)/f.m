
%first we are going to create the function f
function [out1]=f(x,y,k)
out1= floor(rem(floor((y+k)/17).*2.^((-17).*x-rem((y+k),17)),2))
end

