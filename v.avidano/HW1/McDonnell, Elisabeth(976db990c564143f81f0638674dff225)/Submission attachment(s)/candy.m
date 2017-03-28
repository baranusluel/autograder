function [peices, waste]= candy(b,k)
peices= floor(b/k);
waste = mod(b,k);
end