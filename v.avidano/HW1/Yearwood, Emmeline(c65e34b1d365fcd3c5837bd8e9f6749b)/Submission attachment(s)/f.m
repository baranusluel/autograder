function[memes]=f(x,y,k)
exp=-17.*x-rem((y+k),17); %exponent part
frac=floor((y+k)./17);%fraction
input1=frac.*2.^exp;%inside
memes=floor(rem(input1,2));%putting it all together





end