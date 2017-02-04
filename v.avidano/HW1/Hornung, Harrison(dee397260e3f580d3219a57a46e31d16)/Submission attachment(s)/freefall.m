function [pf,vf] = freefall(t)
% Freefall kinematics solver
% Calculates final position and velocity of a falling object using a =
% 9.807m/s and t = change in time.
a = 9.807;
pf = round((a .* t.^2)./2,3);
vf = round(a.*t,3);

end

