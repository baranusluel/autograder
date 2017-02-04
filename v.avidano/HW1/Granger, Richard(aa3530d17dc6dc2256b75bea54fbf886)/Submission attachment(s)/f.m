function [ out ] = f( x , y , k )
%Performs a specific mathematical operation
out = floor(rem(floor((y+k)/17) .* 2 .^ (-17 .* x - rem((y+k) , 17)) , 2))

end