%Distance Formula Function
function d = cartDist(x1, y1, x2, y2)
d = sqrt((x2 - x1).^2 + (y2 - y1).^2);
d = round(d, 2);
end