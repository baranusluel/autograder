function [ pf, vf ] = freefall(t)
%A function to determine position and velocity of an object freefalling
%from rest
%   usage: function [ freefall ] = freefall(p,v,a )
    a = 9.807;  
    p = (a .* t .^2) ./ 2;     
    v = a .* t;
    pf = round( p .* 1000) ./ 1000;  
    vf = round (v .* 1000) ./ 1000;


end

