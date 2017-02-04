function [position, velocity] = freefall(seconds);
position = (9.807 * (seconds)^2)/2;
velocity = 9.807 * seconds;
position = round (position, 3);
velocity = round (velocity, 3);
end