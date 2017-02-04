function [respf,resvf] = freefall(t)
%UNTITLED11 Summary of this function goes here
%usage:function [resvf,respf] = freefall(t)
%had two outputs for the velocity resvf and position respf
%only one imput which was time
%a is a constant not an imput
a = 9.807;
pospt = a .* t^2;
pf = pospt./2;
vf = a .* t;
resvf = round(vf,3);
respf = round(pf,3);

end
