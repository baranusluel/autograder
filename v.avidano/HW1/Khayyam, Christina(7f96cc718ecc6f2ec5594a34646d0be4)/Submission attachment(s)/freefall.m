function [pos,vel]=freefall(t)
%write the equations, use the given accel. constant
%round to thousandth
pos=round(((9.807.*t.^2)/2),3);
vel=round((9.807.*t),3);
end