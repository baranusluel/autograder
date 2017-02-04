function [out1] = cartDist (in1,in2,in3,in4)
cartDist = ((in3-in1)^2+(in4-in2)^2)^(1/2);
out1 = round (cartDist,2);
end

