function   [pos,vel] = freefall(sec)

pos = (9.807.*sec.^2)./2;
vel = 9.807.*sec;
end 
