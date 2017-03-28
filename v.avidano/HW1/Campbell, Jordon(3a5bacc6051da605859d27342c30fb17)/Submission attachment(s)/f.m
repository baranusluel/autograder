function [out] = f(x, y, k)
% I think this is the correct way to write a funtion...


%out = rem(x,y) %This is a test of the function 'rem'
 
%g = rem(y+k,17);
%a = [(y+k)./17].*2.^(17.*x-g);

out = [rem([(y+k)./17].*2.^(17.*x-rem(y+k,17)),2)]



end