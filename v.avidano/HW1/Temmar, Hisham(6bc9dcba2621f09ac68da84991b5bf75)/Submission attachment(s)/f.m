function [result] = f(x,y,k)

%Finds y+k
add = y+k;

%Finds Remainder of y+k over 17
rem1 = rem(add,17);

%Finds (-17*x) minus rem1
 sub1 = (-17.*x)-rem1;

%Raises 2 to the power of sub1
pow = 2.^sub1;

%Floors add over 17
floor1 = floor(add./17);

%Multiplies floor1 and pow
mult1 = floor1.*pow;

%Finds the remainder of mult1 over 2
rem2 = rem(mult1,2);

%Floors rem2, which is the result
result = floor(rem2);
end

