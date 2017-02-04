
function [ dist ] = cartDist( x1, y1, x2, y2 )
%   dist = sqrt((x2-x1).^2+(y2-y1).^2)
arg1 = (x2-x1).^2;
arg2 = (y2-y1).^2;
predist = sqrt(arg1 + arg2);
%round it to the nearest 100th

dist = round (predist.*100)./100;
%checked and working
end