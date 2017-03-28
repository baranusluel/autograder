function [per waste] = candy(total,kids)
per = floor(total./kids);
waste = mod(total,kids);
end