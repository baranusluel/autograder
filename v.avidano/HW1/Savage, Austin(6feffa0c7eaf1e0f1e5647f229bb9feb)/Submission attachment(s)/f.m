function val = f(x,y,k)
val1 = abs((y+k)/17);
val2 = (2.^(-17.*x-rem((y+k),17)));
val = round(abs((rem(val1*val2,2))));
end