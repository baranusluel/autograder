function [out1,out2] = freefall(time)
out1 = roundn(((9.807 .* (time^2)) ./2),-3);
out2 = roundn((9.807 .* time),-3);
%need to round to the thousandths place but there's an output of 1.7664e+03
%instead of 1744.439
end