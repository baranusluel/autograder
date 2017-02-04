function[out] = f(x,y,k)
%Defines three variables to solve a math equation

%Defines the exponent 
myExp= -17*x-rem((y+k),17);

%rasies 2 to the exponent
this= 2.^myExp;

%Gives a final value using the three variables 
out= floor(rem(this*(floor((y+k)/17)),2));

end