function [ pkid, waste] = candy (pieces,kids )
kids = 12;
pieces = 300;
%kids = 13;
%pieces = 34;
pkid = floor( pieces ./ kids)
waste = mod( pieces, kids)
end