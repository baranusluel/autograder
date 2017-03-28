function [pos,vel] = freefall (s)
a=9.807
pos=(a.*(s.^2))/2
vel=a.*s
end

