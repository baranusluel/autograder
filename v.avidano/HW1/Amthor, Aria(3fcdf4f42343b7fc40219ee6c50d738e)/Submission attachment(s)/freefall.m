
%a function that uses kinematic eqns. to determine the position
%and velocity of an object free-falling from rest using the 
%elapsed time as the only input

function [pf, vf] = freefall(t)
    %defines the acceleration due to gravity
    a = 9.807;
    
    %the final postion
    p = (a .* (t .^ 2)) ./ 2;
    
    %the final velocity
    v = a .* t;
    
    %the final position, rounded to the thousandths place
    pf = roundn(p, -3);
    
    %the final velocity, rounded to the thousandths place
    vf = roundn(v, -3);
end