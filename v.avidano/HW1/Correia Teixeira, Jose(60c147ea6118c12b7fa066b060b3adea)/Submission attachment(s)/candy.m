function [ candy_given, candy_wasted ] = candy( candy_total, kids_total )
% this function will determine, out of a given number of candy and given
% number of kids, how much candy each kid gets, and how much is left over
% (waste) after distribution
%   the floor and mod functions will be used. Floor will help truncate the
%   # of candy distributed, whereas mod will help determine the candy
%   wasted

var1 = (candy_total)./(kids_total);
candy_given = floor (var1);
candy_wasted= floor(mod(candy_total,kids_total));

%checked and working
end

