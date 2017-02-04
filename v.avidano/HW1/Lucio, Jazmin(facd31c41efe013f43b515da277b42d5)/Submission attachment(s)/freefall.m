function [ pos,vel ] = freefall(t)
a = 9.807;
X = (a*t.^2);
pos = X/2;
vel = a*t;
N = -3;
round(pos,N);
round(vel,N);
end