function [out] = f(x,y,k)

%Goal is to produce an output from a given function

out = floor(rem(((y + k)./ 17) .* 2.^(-17 .* x - rem(y + k, 17)) , 2));


end