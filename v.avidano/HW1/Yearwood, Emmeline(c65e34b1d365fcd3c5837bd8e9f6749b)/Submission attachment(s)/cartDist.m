function[memes]=cartDist(x1,y1,x2,y2)
x=(x2-x1).^2;%the x2-x1 part inside square root
y=(y2-y1).^2;%y2-y1 inside square root
dist=sqrt(x+y);%formula
memes=round(dist,2);%rounding


end
