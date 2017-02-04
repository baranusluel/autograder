function [pf,vf]= freefall(t);
pf=(9.807.*t.^2)/2 
vf=9.807.*t
end

