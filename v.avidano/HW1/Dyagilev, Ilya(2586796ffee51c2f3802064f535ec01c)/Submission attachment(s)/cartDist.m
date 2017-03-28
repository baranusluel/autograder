function[out] = CartDist(x1,y1,x2,y2)
xdiff = x2 - x1; %x part of dist formula
ydiff = y2 - y1; %y part of dist formula

out = round(sqrt(xdiff.^2 + ydiff.^2),2); % dist formula

end
