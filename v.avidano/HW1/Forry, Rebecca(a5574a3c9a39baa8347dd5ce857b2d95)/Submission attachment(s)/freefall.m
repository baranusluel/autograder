function [posF velF] = freefall(t)
%physics problem of object falling from certain height
velF = 9.807.*t;
p1 = 9.807.* t.^2;
posF = p1./2;
r= 10.^3;
posF= round(r.*posF)./r;
velF= round(r.*velF)./r;
end

