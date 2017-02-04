function [canpkid,canwas] = candy(can,kid)
canpkid=floor(can/kid);%Rounds down and divide the number of candy for every kid.
canwas=mod(can,kid);%The remaining candy after the division.
end

