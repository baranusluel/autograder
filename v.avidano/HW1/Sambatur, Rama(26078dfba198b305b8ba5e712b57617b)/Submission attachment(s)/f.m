function [ output] = f( x, y, k )
exp =(-17.* x)- rem((y+k),17);

idk = ((y+k)./17).*(2.^exp);

output = rem(idk,2);

output = floor(output);

end

