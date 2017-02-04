function [velocity, pos] = freefall(x)
acc = 9.807
pos= (acc*(x^2))/2;
velocity=acc*x;
pos= round(pos,3)
velocity= round(velocity,3)

end