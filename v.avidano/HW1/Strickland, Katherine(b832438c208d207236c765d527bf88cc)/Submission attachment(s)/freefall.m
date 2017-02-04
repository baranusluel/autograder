function [pf,vf] = freefall(t)
a = 9.807;
pf = (a*t.^2)/2; %final position
pf = round(pf,3); %to round to thousandeths place
vf = a*t; %final velocity
vf = round(vf,3); %to round to thousandeths place
end

