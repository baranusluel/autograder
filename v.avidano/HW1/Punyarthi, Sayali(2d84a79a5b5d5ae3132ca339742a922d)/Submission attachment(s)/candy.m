function [candypkid,candywaste] = candy (candy1,kids)%candy 1 = pieces of candy in bag

candypkid = floor ( candy1 ./ kids ); % floor allows the most likely outcome to occur
candywaste = mod (candy1, kids); % the remainder is the candy left over

end