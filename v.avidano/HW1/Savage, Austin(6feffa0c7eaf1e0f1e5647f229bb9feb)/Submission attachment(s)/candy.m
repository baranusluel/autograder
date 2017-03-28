function [kidcand,waste] = candy(numbc,numbk)
waste = mod(numbc,numbk);
kidcand = floor(numbc./numbk);
end