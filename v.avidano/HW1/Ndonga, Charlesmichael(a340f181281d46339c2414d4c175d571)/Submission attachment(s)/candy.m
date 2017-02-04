function[c,r]=candy(b,k)
c=floor((b/k));%floor to eliminate fractions then divide th bagsby children
r=mod(b,k);%by use of mod we will get the reminder 
end