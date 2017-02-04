%% calculate the velocity of an object in freefall
% Inputs:
%   v_i:    The initial velocity in m/s
%   t:      The elapsed time
%
% Outputs:
%   v_f:    The velocity of the object 't' seconds after v_i, assuming on Earth
%%
function [p_f, v_f] = freefall(t)
a = 9.807;
p_f = round((a*t^2)/2, 3);
v_f = round(a*t, 3);

end