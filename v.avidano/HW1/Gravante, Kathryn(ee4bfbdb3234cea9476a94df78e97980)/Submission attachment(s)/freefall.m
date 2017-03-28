function[pf,vf]=freefall(t)
a=9.807
b=t.^2
c=a.*b
d=c./2
pf=d
vf=a*t
end