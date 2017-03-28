function result=f(x,y,k)
step1=rem((y+k),17);
step2=2.^(-17.*x-step1);
step3=floor((y+k)./17);
step4=rem(step3.*step2,2);
result=floor(step4);

end
