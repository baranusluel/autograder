function [pf, vf] = freefall (t)
% gravity (m/(s.^2))
a = 9.807; 
% velocity left
vleft = a .* t;
% final velocity (m/s)
vf = round (vleft, 3); 
% psubleft
psubleft = (t.^2);
% pleft
pleft = (a .* psubleft);
% final position (m)
pf = round(pleft / 2,3); 
end