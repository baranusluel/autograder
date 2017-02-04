function [position,velocity] = freefall (t)
accel = 9.807; %defined acceleration as a variable because assumes constant acceleration
position = (accel .* t.^2) ./ 2;
velocity = accel .* t; 
position = round (position , 3); %rounding variables seperately
velocity = round (velocity , 3); 

end