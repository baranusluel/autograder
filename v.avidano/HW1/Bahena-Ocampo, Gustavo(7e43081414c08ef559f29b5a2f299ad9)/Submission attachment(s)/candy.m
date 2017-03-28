function [perK,waste] = candy(amt,kids)

perK = floor(amt./kids);
waste = rem(amt,kids);
end 
