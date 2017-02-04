function [output] = f(x, y, k)
%This function evaluates the function
%f(x,y,k)=[rem((y+k)/17)*2^(-17*x-rem((y+k,17),2))
%var a is the argument of the encompassing rem function
%var b is the argument of the rem function inside the
%first rem function. 
%floor rounds down the output 
    var a;
    var b;
    b=y+k;
    a=((y+k)/17)*2^(-17*x-rem(b,17));
    output=floor(rem(a,2));
end