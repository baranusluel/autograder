function [p, v] = freefall(t)
a = 9.807; %define acceleration, which is acceleration due to gravity 
speed = a .* t; %find velocity according to physical equation
place = (a .* t .* t) ./ 2; %find position according to physical equation
v = round(speed, 3); %round answer to 3 decimal places
p = round(place, 3); %round answer to 3 decimal places
end