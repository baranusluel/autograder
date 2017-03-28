function [out1] = cartDist (x1, y1, x2, y2)
op1 = y2 - y1; %find difference between y coordinates
op2 = op1 .* op1; %square the difference
op3 = x2 - x1; %find difference between x coordinates
op4 = op3 .* op3; %square the difference
op5 = op4 + op2; %add the squares
ans = sqrt(op5); %then square root the added squares
out1 = round(ans, 2); %round to the hundreth place
end