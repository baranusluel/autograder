function [pos,vel] = freefall(time)

pos = round((9.807*(time.^2))/2,3);
vel = round(9.807*time,3);

end

