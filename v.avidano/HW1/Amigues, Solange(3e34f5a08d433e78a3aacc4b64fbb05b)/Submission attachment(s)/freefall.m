function [out1,out2] = freefall (in1)
a = 9.807;
out1 = (a.* (in1)^(2))/2
out2 = a.* in1
end