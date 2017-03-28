function [ piecesPerKid, wastedCandy ] = candy( bagSize, numberKids )
% candy outputs the number of pieces per kid and 
% wasted candy given the amount of candy in the bag
piecesCandy=bagSize/numberKids;
piecesPerKid=floor(piecesCandy);
wastedCandy=bagSize-(numberKids*piecesPerKid);
end

