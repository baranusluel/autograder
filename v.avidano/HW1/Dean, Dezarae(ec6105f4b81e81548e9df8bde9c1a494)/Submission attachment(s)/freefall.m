function [post, veloc] = freefall(time)
%time = 4;
veloc = (9.807 .* time)

post = ((9.807 .* time .^2) ./ 2);



end