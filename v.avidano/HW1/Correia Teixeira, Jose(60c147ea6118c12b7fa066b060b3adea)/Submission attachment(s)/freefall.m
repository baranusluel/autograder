function [ posf, velf ] = freefall( t )

%   posf refers to the final position of the obeject in meters, whereas
%   velf refers to the final velocity of the object in m/s
% acceleration (a) refers to the acceleration due to gravity (9.807 m/s^2)

a = 9.807;
pposf = (a.*(t^2))/2;
pvelf = a.*t;
%rounding to the nearest 1000th

posf = round (pposf.*1000)./1000;
velf = round (pvelf.*1000)./1000;
%checked and working
end

