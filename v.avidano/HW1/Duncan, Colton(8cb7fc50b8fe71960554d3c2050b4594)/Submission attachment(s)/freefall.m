function [pos1, veloc1]=freefall(t)
a=9.807;
t2=t.^2
p=(a.*(t2))/2;
v=a.*t;
pos1=roundn(p,-3);
veloc1=roundn(v,-3);


end
