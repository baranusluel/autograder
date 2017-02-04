function [ one ] = f( x,y,k )
%Function that solves the equation using the variables x,y,k
%   usage:function [ one ] = f( x,y,k )
    one = floor(rem (floor(y+k ./ 17 ).* 2 .^(-17.*x-rem((y+k),17)),2));  %I rewrote the function using matlab terms

end

