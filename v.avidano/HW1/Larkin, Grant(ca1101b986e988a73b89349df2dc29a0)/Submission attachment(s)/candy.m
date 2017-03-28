function [out1,out2] = candy(numberofcandy,kids)
%variable that gives the lowest whole number of candy divided by kids
var1 = floor(numberofcandy ./ kids);

%var2 gives the number of pieces of candy used
var2 = var1 .* kids;

%var3 gives pieces of candy wasted
var3 = numberofcandy - var2;

out1 = var1;
out2 = var3;
end


