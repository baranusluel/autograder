function[perkid,waste]=candy(s,chillins)
%divide the candy per kid and floor it
perkid=floor(s./chillins);
%identify what is left over-"the waste"
waste=mod(s,chillins);
end

