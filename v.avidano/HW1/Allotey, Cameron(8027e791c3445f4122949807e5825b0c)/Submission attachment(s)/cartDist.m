function[dist]=cartDist(x1,y1,x2,y2)
%Distance formula

%Finds the squares of the differences of the two variables
xSq=(x2-x1).^2;
ySq=(y2-y1).^2;

%Takes the square root of the full equation
dist= sqrt(xSq+ySq)
dist=round(dist,2)

end