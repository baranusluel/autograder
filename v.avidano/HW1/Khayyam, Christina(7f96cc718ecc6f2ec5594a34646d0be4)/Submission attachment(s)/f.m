function out=f(x,y,k)
%use equation provided on the sheet, then round
out=floor(rem(abs((y+k)/17).*2.^(-17.*x-rem((y+k),17)),2));
end