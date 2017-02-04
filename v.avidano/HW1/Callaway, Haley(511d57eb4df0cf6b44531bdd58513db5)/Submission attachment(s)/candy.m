function [kidcandy, wastedcandy] = candy(pieces,kids)
kidcandy = floor((pieces/kids)); %floor divison of candy pieces by kids
wastedcandy = mod(pieces,kids); %leftover pieces from piececs divided by kids
end