function [perkid,wasted] = candy(candies,kids)
% Calculate number of candy pieces per kid, and number of wasted pieces
% usage: function [perkid,wasted] = candy(candies,kids)
[perkid] = floor(candies/kids);
[wasted] = rem(candies,kids);
end