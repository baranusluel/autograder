function [peiceskid,peiceswasted]= candy(candynum,kidnum)
a = candynum./kidnum;
peiceskid = floor(a)
peiceswasted = candynum - kidnum.*peiceskid 
end
