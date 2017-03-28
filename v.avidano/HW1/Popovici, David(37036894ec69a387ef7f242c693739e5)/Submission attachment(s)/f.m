%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function Description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Function Name: f

%Inputs:
%1. (double) An x value
%2. (double) A y value
%3. (double) A k value

%Outputs:
%1. (double) The resulting value of the function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%This problem is designed to illustrate the fact that MATLAB functions are similar to math
%functions that you are familiar with. 

%Write a function in MATLAB that will evaluate the function
%f(x, y, k) .

%There are built-in MATLAB functions for floor, remainder and exponentiation ( floor() ,
%rem() , and .^ , respectively). 

%Feel free to use the help function in the Command Window to
%look up these or any other built-in functions you may be confused about.

%If this functions seems needlessly complex, just wait. It has a very interesting property
%that will be explored in a later homework :)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function output = f(x,y,k) 
output = floor(rem(floor((y+k)/17).*2.^(-17.*x-rem(y+k,17)),2));

disp(output)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%[out1] = f(2, 3, 4)
% 	out1 => 0
%Status: PASSED

% [out2] = f(0, 3, 1292)
% 	out2 => 1
%Status: PASSED

%COMPLETED