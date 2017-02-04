function[out1,out2] = freefall (t)
a=9.807;
out1= (a*t^2)/2;
out2= (a*t);
[out1]=round(out1,3);
[out2]=round(out2,3);
end 
