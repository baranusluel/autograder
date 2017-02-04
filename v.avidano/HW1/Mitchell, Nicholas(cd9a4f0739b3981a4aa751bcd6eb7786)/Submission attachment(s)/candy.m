function [cpk,cw] = candy (cpb, k)
cpk=floor(cpb/k)
cw=mod(cpb,k)
end