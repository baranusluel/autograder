function [finalposition, finalvelocity] = freefall (time)
positionunrounded = (9.807.*(time).^2)./2;
finalposition = (round(positionunrounded.*1000))./1000
velocityunrounded = 9.807.*time;
finalvelocity = (round(velocityunrounded.*1000))./1000
end