function [out1] = f(x, y, k)
% Usage:    function [out1] = f(x, y, k)
  
    a = -17 .* x-rem((y+k),17)
    b = (y + k) ./ 17
    c = floor(b) .* 2 .^ (a)
    d = rem(c ,2)
    out1 = floor(d);

% out1 = floor(rem(floor((y + k) ./ 17) .* 2 .^ (-17 .* x-rem((y+k),17)),2));
end

