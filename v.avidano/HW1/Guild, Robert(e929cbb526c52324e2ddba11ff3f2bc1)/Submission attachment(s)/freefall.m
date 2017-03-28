function [out1,out2] = freefall(t)
xi = (9.807.*t.^2)./2;
out1 = round(xi,3);
vi = 9.807.*t;
out2 = (vi.*100./100);
end
