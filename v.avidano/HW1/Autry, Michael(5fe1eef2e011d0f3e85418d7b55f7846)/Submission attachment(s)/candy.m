function [cpk, cw] = candy (pieces, kids)
cw = mod(pieces,kids) ;
cpk = floor(pieces / kids);
end
