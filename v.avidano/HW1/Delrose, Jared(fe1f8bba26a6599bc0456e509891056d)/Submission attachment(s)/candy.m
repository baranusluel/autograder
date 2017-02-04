function [ckid, cwast] = candy(ncnd, nkid)
% First find the largest integer amount of candy each kid can possibly get
ckid = floor(ncnd ./ nkid);
% Next find how much is wasted by figuring out the remainder from that
% division
cwast = mod(ncnd,nkid);
