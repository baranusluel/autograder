function[d,v]=freefall(t)
a=9.807;% its a constant 
d=a*t*t;
d=round(d/2,3);
v=round(a*t,3);
end
