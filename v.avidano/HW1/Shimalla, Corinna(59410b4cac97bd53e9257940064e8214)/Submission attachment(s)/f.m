function [res] = f (x, y, k)
part1 = floor((y + k) ./ 17);
part2 = 2 .^(-17 .* x - rem((y + k), 17));
res = floor( rem( part1 .* part2,2));
end