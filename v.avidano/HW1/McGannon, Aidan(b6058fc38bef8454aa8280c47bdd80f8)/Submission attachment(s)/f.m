function [ alpha ] = f( x , y , k )
% Evaluate the function f at values x, y , k.
beta = (y + k);
gamma = (beta./17);
delta = floor(gamma);
epsilon = rem(beta,17);
zeta = (-17*x)-epsilon;
eta = 2 .^ zeta ;
theta = delta .* eta ;
iota = rem(theta,2);
alpha = floor(iota);
end

