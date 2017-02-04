function [finalP, finalV] = freefall(time) 
a = 9.807;
finalP = ((a .* (time .^2)) ./ 2);
finalP = round(finalP, 3);

finalV = (a .* time);
finalV = round(finalV, 3);
end