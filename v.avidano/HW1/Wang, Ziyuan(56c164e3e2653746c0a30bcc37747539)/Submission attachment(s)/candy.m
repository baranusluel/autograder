function [out1,out2] = candy(in1,in2)
out1 = floor(in1./in2)
out2 = mod(in1,in2)
end