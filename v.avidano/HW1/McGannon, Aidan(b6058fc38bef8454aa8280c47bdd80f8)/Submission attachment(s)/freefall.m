function [pf, vf] = freefall(t)
% The function will be able to determine the position and velocity of an
% object after a certain amount of time falling
a = 9.807 ;
pf = (a .* t .^2) ./ 2 ;
vf = (a .* t) ;
pf = round( pf,3);
vf = round( vf,3);
end

