function [ppk,wst]=candy(ppb,kids)
% This function will determine the ammount of candy each kid gets and the
% ammount leftover from the amount of candy in the bag and the number of
% kids.
    ppk=floor(ppb/kids);
    wst=mod(ppb,kids);
end