function [pf vf] = freefall(t)
%Define acceleration
a = 9.807; 
%For final position, t squared
ts = t.^2;
%Numerator of final position
num = a.*ts
%Numerator divided by 2, before rounding
pf1 = num./2
%For Final velocity, before rounding
vf1 = a.*t
pf = round(pf1,3)
vf = round(vf1,3)
end


