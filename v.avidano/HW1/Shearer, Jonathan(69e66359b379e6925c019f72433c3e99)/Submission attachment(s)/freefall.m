function [Pf,Vf] = freefall(sec)
%Pf = position of falling object
%Vf = velocity of falling object
Pf=((9.807.*(sec.^2))./2);
Vf=(9.807.*sec);
Pf = round(Pf,3);
Vf = round(Vf,3);

end