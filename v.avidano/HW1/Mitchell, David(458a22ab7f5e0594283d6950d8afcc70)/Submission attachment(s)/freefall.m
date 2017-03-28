function [po,vo] = freefall(t)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
    p = ((9.807.*(t.^2))./2);
    po = round(p, 3)
    v = (9.807.*t);
    vo = round(v, 3) 
end

