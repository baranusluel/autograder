function [fnpos, fnvelo] = freefall (time)
a = 9.807;
%constant for acceleration due to gravity
numerator = a.*(time.^2);
%calculates the numerator of the position formulaa
fnpos = round(numerator./2,3);
%calculates the final position rounded to thousandths place
fnvelo = round(a.*time,3);
%calculates the final velocity rounded to the thousandths place
end