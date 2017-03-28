function[position,velocity] = freefall(time)
position = (9.807*(time^2))/2;
velocity = 9.807*time;
position = round (position,3)
velocity = round (velocity,3)
end