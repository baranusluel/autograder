function [distance] = cartDist(x1, y1, x2, y2)

% Goal is to find distance between two catesian coordinates
% Also to round to the hundereth's place
% Formula to do so is distance = sqrt((x2 - x1).^2 + (y2 - y1).^2)

distance = round(((x2 - x1).^2 + (y2 - y1).^2).^.5,2) ;

end