function [pos vel] = freefall(time)

%This sets acceleration
acc = 9.807;

%This finds the time squared
sqt = time.^2;

%This multiplies acceleration by time squared
top = acc.*sqt;

%This divides top by 2, and rounds the result to the thousandths, giving the position
pos = roundn(top./2,-3);

%This multiplies acc by time, and rounds the results to the thousandths, giving velocity
vel = roundn(acc.*time,-3);
end
