function [pos,vel] = freefall(sec)
pos = round(((9.807.*sec.^2)/2),3);
vel = round((9.807.*sec),3);