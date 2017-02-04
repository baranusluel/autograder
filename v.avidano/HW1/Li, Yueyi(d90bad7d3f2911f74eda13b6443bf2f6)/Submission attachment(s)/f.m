function [ out ] = f( x,y,k )
%chicken chicken chicken chicken
a = (y+k)/17;
b = -17.*x-rem((y+k),17);
out = rem(a.*2.^b,2);

end

