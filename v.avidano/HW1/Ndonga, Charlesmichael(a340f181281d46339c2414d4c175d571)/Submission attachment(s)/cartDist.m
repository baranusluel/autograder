function[distance]=cartDist(x1,y1,x2,y2)
xdist=x2-x1;
ydist=y2-y1;
dis1=xdist.^2+ydist.^2;
distance=sqrt(dis1);
distance=ceil(distance);

end