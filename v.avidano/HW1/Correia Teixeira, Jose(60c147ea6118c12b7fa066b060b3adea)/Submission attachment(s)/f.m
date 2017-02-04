
function [output] = f( x,y,k )
%checked and working
var1 = floor((y+k)./17);
var2 = (-17.*x)-rem((y+k),17);
var3 = 2.^var2;
%var4 will equal var1 times var3
var4 = var1.*var3;
output = floor(rem (var4,2));

end

