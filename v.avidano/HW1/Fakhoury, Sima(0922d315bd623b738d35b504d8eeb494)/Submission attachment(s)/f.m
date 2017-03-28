function value = f(x, y, k)
part1 = ((y+k)./17)
part2 = 2.^((-17.*x)-rem((y+k),17))
part3 = rem(part1.*part2,2)
value = floor(part3)
end
