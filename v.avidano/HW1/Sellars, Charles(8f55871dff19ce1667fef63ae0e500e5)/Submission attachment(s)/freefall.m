function [fp , fv] = freefall(time)
a = 9.807; %set the value for a from the given data
fp = (a.*time.^2)/2; % multiplies a by the variable time squared the 
%divides the product by two then assigning the value to fp or final
%position
fv = a.*time; % multiplies a by the variable time again but does not divide
%this value is then assigned to fv
fp = round(fp.*1000); %the bottom four lines of code clean up the variables 
%and round to nearest interger.
fp = fp./1000;
fv = round(fv.*1000);
fv = fv./1000;
end