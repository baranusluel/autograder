function [pos, veloc] = freefall(time)
%set acceleration to standard
acc = 9.807;
%calculate final position
pos = (acc*time^2)/2;
%calculating the final velocity
veloc = acc*time;
%round position
pos = round (pos, 3);
%round velocity
veloc = round(veloc, 3);
end