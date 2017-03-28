function [cpk,cw]= candy (c,nk)
cpk= floor (c./nk)
cw=c-(cpk.*nk)
end 
