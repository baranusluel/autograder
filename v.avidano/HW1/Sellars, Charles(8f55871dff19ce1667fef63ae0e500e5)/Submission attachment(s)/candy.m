function [pcp, pcw] = candy(npc, nk)
pcw = mod(npc,nk); %finds the number of candy of wasted by using the modulus
% function and then assigning it to pcw.
pcp = npc-pcw; % to find the pieces of candy per child I first substracted
% pcw from the initial pieces of candy variable
pcp = pcp./nk; % I then divided by the number of kids variable to get the final
% output
end