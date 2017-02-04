function [res]=f(x,y,k)
% This fucntion is supposed to match the first drill problem of hw01
% f(x,y,k)=floor(rem(floor((y+k)/17))(2^(-17*x-rem((y+k),17))),2)))
    A=rem((y+k),17);
    B=-17*x-A;
    C=2.^(B);
    D=(y+k)/17;
    E=floor(D);
    F=rem(E*C,2);
    res=floor(F);
end