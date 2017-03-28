function [pf,vf] = freefall(t)
pf = round(0.5.*9.807.*t.^2,3)
vf = round(9.807.*t,3)
end