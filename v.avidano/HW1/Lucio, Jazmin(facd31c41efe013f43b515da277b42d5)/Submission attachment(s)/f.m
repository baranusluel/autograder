function [ res1 ] = f(x,y,k)
R = rem((y+k),17);
E = (-17)*x-R;
M = (y+k)/ 17;
res1 = rem(M*2.^E,2);
round(res1);
end
