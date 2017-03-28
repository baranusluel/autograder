function[out1,out2]=candy(nc,nk)

%number of candy per child 
out1=floor(nc./nk);
%number of candy wasted
out2=mod(nc,nk); 




end
