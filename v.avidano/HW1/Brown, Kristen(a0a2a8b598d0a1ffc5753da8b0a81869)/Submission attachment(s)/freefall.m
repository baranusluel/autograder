function [xf vf]=freefall(t)
xf=(9.807 .* (t.^2))./2;%calculates position unrounded
vf=(9.807.*t);%calculates velocity unrounded
xf=round(xf,3);%rounds xf to nearest thousandth
vf=round(vf,3);%rounds vf to nearest thousandth
end