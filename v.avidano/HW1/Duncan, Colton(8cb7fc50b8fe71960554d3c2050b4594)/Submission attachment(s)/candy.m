function [cpk, cw]= candy(numcandy, numkids)
cpk= floor(numcandy/numkids);
cw= mod(numcandy, numkids);


end