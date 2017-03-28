function [candyperKid, candyWasted] = candy(numCandy, numKids)  %%function header
candyperKid = floor(numCandy/numKids);   %%%candy each kid will receive 
candyWasted = mod(numCandy,numKids);    %%%candy that will be wasted
end    %%%% end of function
