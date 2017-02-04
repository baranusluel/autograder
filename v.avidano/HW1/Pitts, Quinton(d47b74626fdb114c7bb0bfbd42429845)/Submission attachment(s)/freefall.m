function [pos , veloc] = freefall(t)

% Goal is to find the final position and velocity of a free falling object
% Once this is found you must round to the thousandth's place
% formulas used are pos = (a*t^2)/2 and veloc = a*t

a = 9.807;

pos = round(((a .* t.^2) / 2), 3);

veloc = round((a .* t), 3);

end