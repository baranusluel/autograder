function [ p,v ] = freefall( t )
%p is the final position, v is final velocity, a is the acceleration
%   freefall kills; the final position also kills

a = 9.807;
p = round((a.*t.^2)./2.*1000)./1000;
v = round(a.*t.*1000)./1000;
end

