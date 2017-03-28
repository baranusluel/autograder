function [fpos, fvel] = freefall (timeinsec)
accel = 9.807; %set the value of gravity
fpos = round(((accel.*timeinsec.^2) ./ 2),3) %round the position formula with acceleration and time
fvel = round((accel.*timeinsec),3) %round the velocity formula with acceleration and time
end