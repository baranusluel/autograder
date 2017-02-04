function [distance] = cartDist (x1, y1, x2, y2)
determinant = (x2 - x1).^2 + (y2 - y1).^2 %find the value of everything inside the square root by using distance formula
distance = round(sqrt(determinant),2)%find square root of determinant and round to nearest hundreth
end