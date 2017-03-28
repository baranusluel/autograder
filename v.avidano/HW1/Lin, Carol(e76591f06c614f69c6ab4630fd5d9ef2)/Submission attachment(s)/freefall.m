function [position, velocity] = freefall(time)

a = 9.807;
t = time;
position = (a*t.^2)/2;
velocity = a*t;

position = round(position,3);
velocity = round(velocity,3);

end