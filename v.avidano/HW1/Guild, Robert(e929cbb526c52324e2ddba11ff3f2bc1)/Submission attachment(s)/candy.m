function [out1, out2] = candy(pieces,kids)
out2 = mod(pieces,kids);
out1 = floor(pieces./kids);
end