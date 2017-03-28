function [pos,vel] = freefall(t)
pos=round(9.807*(t^2)/2,3);%Uses the formula and the variable t to calculate position.
vel=round(9.807*t,3);%Uses the formula and the variable t to calculate velocity.
end

