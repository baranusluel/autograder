function [disttopo] = cartDist(xf,yf, xs, ys)
xt = (xs-xf).^2; %These two lines first subtract initial coordinate from the 
%final coordinate then squared the difference
yt = (ys-yf).^2;
disttopo = round(sqrt(xt+yt).*100); % I then used the ceiling function to 
%round up the square root of the sum of the variables xt and yt. Next I
% multiplied by hundred to clean up the variable.
disttopo = disttopo/100; %This cleans up the final variable to make sure it 
% has the proper sig figs.
end