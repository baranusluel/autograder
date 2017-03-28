function[pos,vel] = freefall(t)
%Calculates free fall velocity and final position

g= 9.807; %gravity constant

%Solves for position and velocity and rounds to the thousandths place
pos= (g*t.^2)/2;
vel= g*t;
pos= round(pos,3);
vel= round(vel,3);

end