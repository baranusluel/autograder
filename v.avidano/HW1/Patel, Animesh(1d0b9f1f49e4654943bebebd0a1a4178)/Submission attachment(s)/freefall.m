function [pf, vf] = freefall(t)  %%function header
a = 9.807;  %% value of acceleration
pf = round(((a*t^2)/2),3);  %%%final position
vf = round((a*t),3);   %%%final velocity
end  %% end of function