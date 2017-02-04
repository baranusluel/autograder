function [out1] = f(x,y,k)

exp = -17 .*x-rem((y+k),17);
inner = floor((y+k)./17);
out = rem(inner.*2.^exp,2);
out1 = floor(out);

end
