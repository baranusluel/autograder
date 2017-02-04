function [ cpk, cw  ] = candy( tot, kids )

cpk = tot./kids;
cpk = floor(cpk);
cw = rem(tot, kids);

end

