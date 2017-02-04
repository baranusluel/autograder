function [pos, vel] = freefall (time)
a = 9.807
pos = (a.*(time).^2)./2;
vel = a.* time
pos = round(pos.*1000)./1000
vel = round(vel.*1000)./1000
end
