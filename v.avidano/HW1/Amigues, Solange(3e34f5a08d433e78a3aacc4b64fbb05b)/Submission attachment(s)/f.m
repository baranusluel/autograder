
function [out1] = f(x,y,k)
out1 = (y+k)/17*2^(-17*x-rem(x+k,17))
f = floor (rem(out1,2))
end


