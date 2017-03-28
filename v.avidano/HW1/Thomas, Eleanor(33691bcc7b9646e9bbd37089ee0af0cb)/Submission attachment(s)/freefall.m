function [position, velocity] = freefall(t)
a = 9.807 ;
position = (a .* t.^2) ./ 2 ;
velocity = a .* t ;
end