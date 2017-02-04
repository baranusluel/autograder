function [ per_kid,wasted ] = candy( p,k )
%per_kid is the pieces of candy per kid; 
% wasted is the pieces of candy wasted
%   p is the number of pieces of candy in the bag
%   k is the number of kids

per_kid = floor(p./k);
wasted = mod(p,k); 

end

