function [answer] = f(x,y,k)
% f function 
% used to solve given equation f(x,y,k)

a = floor( (y+k) ./ 17);
b = -17.*x-rem((y+k),17);
c = 2 .^b;
d = a .* c;
answer = floor(rem(d,2));

end


