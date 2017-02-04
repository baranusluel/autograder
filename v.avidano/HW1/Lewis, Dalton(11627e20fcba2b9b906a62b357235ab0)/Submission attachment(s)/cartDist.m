function [out1] = cartDist (x, y, xx, yy)
% Calculate the cartesian distance from P1 to P2
% Usage:    function [out1] = cartDist (x, y, xx, yy)

    dx = xx-x;
    dy = yy-y;
% Local Distance (x2-x1) (y2-y1)

    z = dx .^ 2 + dy .^ 2;
    a = sqrt(z);
% Square root of the addition of local distances

    out1 = round(a, 2);
% Rounding to hundredth
end
