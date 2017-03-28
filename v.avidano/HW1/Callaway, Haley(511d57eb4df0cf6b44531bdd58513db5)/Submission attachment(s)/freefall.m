function [output1, output2] = freefall(s)
output1 = (9.807.*s^2)/2; %position formula, a = 9.807
output1 = round(output1,3);%round output to thousandths
output2 =  9.807.*s; %velocity formula
output2 = round(output2,3); %round to thousandths
end
