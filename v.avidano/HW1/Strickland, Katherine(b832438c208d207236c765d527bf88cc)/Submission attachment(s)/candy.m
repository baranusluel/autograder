function [candykid,candywasted] = candy(np,nk)
candykid = floor(np/nk); %to determine number of pieces per kid 
candywasted = mod(np,nk); %to determine candy wasted
end