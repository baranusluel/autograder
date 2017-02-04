function [out] = f(x,y,k)
outtemp = floor((y+k)./17).*(2.^((-17.*x)-rem((y+k),17)));
out = floor(rem(outtemp,2));
end
