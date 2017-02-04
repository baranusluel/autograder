function [ pf , vf ] = freefall( t )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
a = 9.807; 
pf = a .* ( t .^2 ) ./ 2;
pf = round ( pf , 3);
vf = a .* t;
vf = round ( vf , 3);


end

