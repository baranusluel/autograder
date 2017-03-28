function[out1,out2]=candy(in1,in2)
a=(in1/in2);
[out1]=floor(a);
[out2]=mod(in1,in2);
end

