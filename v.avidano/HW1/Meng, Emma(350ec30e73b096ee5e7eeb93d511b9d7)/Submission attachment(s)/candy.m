function [candyperkid,thrownout] = candy (num, numkids)
%Round peices of candy divided by kids down to nearest int
candyperkid = floor(num/numkids);
thrownout = mod(num, numkids);

end