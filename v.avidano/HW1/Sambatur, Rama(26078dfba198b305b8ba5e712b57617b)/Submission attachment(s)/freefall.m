function [ pf, vf ] = freefall( t )
a = 9.807;
pf = (a.*t.^2)./2;
vf = a.*t;
pf= round(pf, 3);
vf= round(vf, 3);

end

