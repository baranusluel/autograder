function [pos, veloc] = freefall(time)
pos = (9.807*time.^2)./2;
veloc = 9.807 * time;
pos = round(pos*1000)./1000;
veloc = round(veloc*1000)./1000;
end