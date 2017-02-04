function [s,v]=freefall(t)
% This function will determine the position and velocity, as a function of time, of an object free
% falling from rest.
    g=9.807;
    s0=(g*t.^2)/2;
    v0=g*t;
    s=round(s0,3);
    v=round(v0,3);
end