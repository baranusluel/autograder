function [pieces, wasted] = candy(bagSize, numKids)
    % Calculate the number of pieces per kid
    pieces = floor(bagSize ./ numKids);
   
    % Calculate the wasted pieces of candy
    wasted = mod(bagSize, numKids);
end