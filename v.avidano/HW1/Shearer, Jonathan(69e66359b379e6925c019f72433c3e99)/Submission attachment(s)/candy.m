function [ppk,waste] = candy(pieces,kids)
%ppk = pieces per kid
%waste = # of pieces of candy wasted
%this function calculates the pieces per kid and the amount of wasted candy
%using the input of pieces and kids
ppk = floor(pieces./kids);
waste = mod(pieces,kids);
end