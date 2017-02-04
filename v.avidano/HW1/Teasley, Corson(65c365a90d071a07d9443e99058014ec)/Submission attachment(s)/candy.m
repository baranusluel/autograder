function [out1, out2] = candy (x,y)
%x=# of candy in bag
%y=# of kids
%out1= pieces of candy per kid
%out2= pieces of candy wasted

out1= floor (x / y);
out2 = rem (x, y);
end