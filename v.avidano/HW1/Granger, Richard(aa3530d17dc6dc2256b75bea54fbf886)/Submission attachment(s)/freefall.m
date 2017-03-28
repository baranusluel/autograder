function [ pos , vel ] = freefall( sec )
%freefall Calculates position and velocity given an input of seconds under
%a constant acceleration

pos = round(.5 .* (9.807 .* sec .^ 2) , 3)

vel = round(9.807 .* sec , 3)

end