function dist=cartDist(x1,y1,x2,y2)
dist=sqrt(((x2-x1).^2)+((y2-y1).^2));%does the pythag thrm
dist=round(dist,2);%rounds to nearest hundreth
end
