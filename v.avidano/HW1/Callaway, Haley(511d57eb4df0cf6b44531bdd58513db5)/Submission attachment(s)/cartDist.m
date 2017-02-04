function [output] = cartDist(x1,y1,x2,y2)
[output] = sqrt((x2-x1).^2+(y2-y1).^2); %distance formula
[output] = round(output,2); %round to hundredths
end
