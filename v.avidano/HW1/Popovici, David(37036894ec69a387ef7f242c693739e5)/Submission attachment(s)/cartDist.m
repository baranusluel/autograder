%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function Description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Function Name: cartDist

%Inputs:
%1. 1. (double) The first point's x-coordinate (x1 )
%2. (double) The first point's y-coordinate (y1 )
%3. (double) The second point's x-coordinate (x2 )
%4. (double) The second point's y-coordinate (y2 )

%Outputs:
%1. (double) The distance between the two points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%This function will take in two points defined in 2 dimensional space and calculate the
%distance between them. 

%The points will be represented using Cartesian coordinates in the form
%[x 1 , y 1 ] and [x 2 , y 2 ]. 

%In case you are rusty on your geometry, the distance between two points can be calculated 
%using the following formula:
%distance = ?(x2 ? x1) y )^2 + ( 2 ? y1)^2

%Round the distance to the nearest hundredth.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function output = cartDist(x1, y1, x2, y2)
output = round(sqrt((x2-x1).^2+(y2-y1).^2),2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%[dist1] = cartDist(4, 5, 7, 9)
% 	dist1 => 5
%*Status: PASSED

%[dist2] = cartDist(4, 3, -7, -10)
%	dist2 => 17.03 
%*Status: PASSED

%[dist3] = cartDist(0, 0, 0, 0)
%	dist3 => 0
%*Status: PASSED

%COMPLETED