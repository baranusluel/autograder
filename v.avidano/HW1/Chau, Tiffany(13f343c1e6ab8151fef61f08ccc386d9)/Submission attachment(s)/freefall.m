function [position, velocity] = freefall(t)
%this function solves for the final position and 
%final velocity of an object in freefall at a certain
%time. var a gives the constant acceleration, var b 
%solves for the final position and var c solves for 
%the final velocity. both values are then rounded to
%a certain number of decimal points, where n=-3 for 
%thousandths place. 
    var a;
    var b;
    var c;
    a=9.807;
    b=(a*t^2)/2;
    c=a*t;
    position=roundn(b,-3);
    velocity=roundn(c,-3);
end