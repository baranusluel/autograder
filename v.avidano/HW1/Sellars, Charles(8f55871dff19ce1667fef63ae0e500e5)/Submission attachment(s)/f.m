function [sol] = f(x,y,k)
u= y+k; % assigns u as the sum of the y and k variables together to
% less clutter in my work and function
q = (-17).*x-rem(u,17); % assigns q as the product fo negative seventeen
%and x then subtracs the remainder of u divided by seventeen;
sol = floor(rem((u/17).*2.^(q),2)); %assigns value sol by rounding down to
% the next interger of the remainder of the quotient of u divided by
% seventeen times two to the power of q and then divides that by 2.
end