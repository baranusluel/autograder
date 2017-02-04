function [pf, vf] = freefall(t)
pf = .5 * (9.807) * t^2;
vf = (9.807) * t;
[pf] = round(pf, 3);
[vf] = round(vf, 3);
end