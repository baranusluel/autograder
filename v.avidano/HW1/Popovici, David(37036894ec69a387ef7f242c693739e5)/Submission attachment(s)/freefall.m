%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function Description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: freefall
%%
%Inputs:
%1. (double) An amount of time in seconds

%Outputs:
%1. (double) The final position of the falling object in meters
%2. (double) The final velocity of the object in meters/second

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%You've gotten tired of solving the same kinematics problems in physics, so you decide to
%automate the process using MATLAB. This function will determine the position and velocity of
%an object free-falling from rest. 

%You can assume a constant acceleration of 9.807 m/s and no air
%resistance. The following are the formulas for position and velocity.
%pf = 2
%a*t2
%vf = a * t

%where p f is the final position, v f is the final velocity, a is the acceleration of the object, and t is the
%elapsed time.

%Round your final answer to the thousandths place.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [pos1, veloc1] = freefall(t)
a = 9.807;
pos1 = (round((a.*t.^2)./2,3)); 
veloc1 = (round(a.*t,3)); 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% [pos1, veloc1] = freefall(4)
% 	pos1 => 78.456
% 	veloc1 => 39.228
%Status: PASSED
% 
% [pos2, veloc2] = freefall(3.2)
% 	pos2 => 50.212
% 	veloc2 => 31.382
%Status: PASSED
% 
% [pos3, veloc3] = freefall(18.98)
% 	pos3 => 1766.439
% 	veloc3 => 186.137      
%Status: PASSED

%COMPLETED