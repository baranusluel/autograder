function[cpc,wast]= candy(numCand,numKids)
%Calculates amount of candy each kid gets at party

cpc = floor(numCand/numKids);
wast = mod(numCand,numKids);

end