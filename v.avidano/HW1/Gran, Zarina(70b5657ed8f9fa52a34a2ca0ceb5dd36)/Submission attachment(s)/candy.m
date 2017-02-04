function [saved wasted] = candy(bag, kid)
%The amount distributed is found by first dividing
dist = bag./kid
%The amount of candy saved is rounded down so everyone has the same amount
%of candy
saved = floor(dist)
%The amount of candy wasted is the remainder of the divided amont
wasted = mod(bag, kid)
end
