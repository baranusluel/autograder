function [dist] = cartDist(X_a,Y_a,x_b,y_b)
%distance formula, then round
dist=round(sqrt((x_b-X_a).^2+(y_b-Y_a).^2),2);
end