function out = f(x,y,k)


b = ((y+k./17).*2).^ (-17.*x)-rem((y+k),17);
out = abs(rem(b,2));

end