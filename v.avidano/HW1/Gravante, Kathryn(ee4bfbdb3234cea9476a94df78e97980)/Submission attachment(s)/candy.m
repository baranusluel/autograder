function[piecesk, waste]=candy(piecesb, kids)
p=piecesb./kids;
piecesk=floor(p);
m=piecesk.*kids;
waste=piecesb-m
end