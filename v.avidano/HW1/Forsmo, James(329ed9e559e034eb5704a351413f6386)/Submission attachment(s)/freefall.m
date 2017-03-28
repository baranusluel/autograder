function [ pos,vel ] = freefall(t)
    %calculates the final position and velocity of an object
    %after 't' seconds of free-fall, with downward acceleration
    %equal to 9.807 m/s
    %inputs: time in seconds
    %outputs: final position (meters) and final velocity (meters/second)
    accel = 9.807;
    
    %calculate final position
    pos = (accel .* (t.^2))./ 2;
    
    %calculate final velocity
    vel = (accel .* t);
end

