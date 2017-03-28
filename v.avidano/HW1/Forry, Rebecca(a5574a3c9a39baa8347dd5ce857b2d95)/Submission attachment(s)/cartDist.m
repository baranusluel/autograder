function [out] = cartDist(x1,y1,x2,y2)
par1= (x2-x1).^2;
par2= (y2-y1).^2;
par3= par1 + par2;
out= sqrt(par3);%out bc answer
f= 10.^2;%rounding to the hundredth
out=round(f*out)/f;%divide by f to reverse step 6
end

