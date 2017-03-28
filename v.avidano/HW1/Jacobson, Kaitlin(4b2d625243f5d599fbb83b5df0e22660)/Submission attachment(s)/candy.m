function [eat, waste] = candy(piece, kid)
yum = piece ./ kid; %divide total candy by the amount of kids
eat = floor(yum); %round the answer down becasue you can't give partial candy
waste = piece - (eat.*kid); %find the leftovers
end