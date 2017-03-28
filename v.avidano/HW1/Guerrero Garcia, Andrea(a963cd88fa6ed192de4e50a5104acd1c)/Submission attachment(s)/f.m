function [result]=f(x,y,k)
exp=-17.*x-rem((y+k),17)
floor1= floor((y+k)/17)
inside=floor1.*(2.^exp)
rem1=rem(inside,2)
result=floor(rem1)
end 

