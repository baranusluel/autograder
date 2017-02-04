function [pf, vf] = freefall(t)
a = 9.807;
pf = ( a .* (t .^ 2) ) ./ 2;
vf = a .* t;
pf = round(pf .* 1000) ./ 1000;
vf = round(vf .* 1000) ./ 1000;
end

