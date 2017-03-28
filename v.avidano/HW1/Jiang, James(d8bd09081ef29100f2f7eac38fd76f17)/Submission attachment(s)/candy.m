function [give, waste] = candy (bag, kids)
waste= mod (bag,kids);
give= (bag-waste)/kids;
end
