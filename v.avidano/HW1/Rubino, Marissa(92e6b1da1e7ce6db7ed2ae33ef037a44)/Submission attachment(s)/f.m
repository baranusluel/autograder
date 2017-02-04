function result = f(x ,y ,k)
param1 = (y+k)./17;
a = rem(y+k,17);
param1 = floor(param1);
param2 = 2.^((-17.*x)-a);
b = param1*param2;
result = floor(rem(b,2));

end