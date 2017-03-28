function[out1,out2] = freefall(t)
a = 9.807;  % gravity constant
out1 = abs(round((-a.*t.^2)/2,3));  %position formula rounded to thousands
out2 = round(a*t,3);  %velocity formula rounded to thousands
end
