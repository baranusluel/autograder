function [fred] = f(x, y, k)

% used function given in the drill problems. 

a = (y + k);
b = a ./17;
c = floor(b);
d = rem(a, 17);
e = -17 .*x;
f = e - d;
g = 2 .^f;
h = c .*g;
almostFred = rem(h, 2); 
fred = floor(almostFred);

end