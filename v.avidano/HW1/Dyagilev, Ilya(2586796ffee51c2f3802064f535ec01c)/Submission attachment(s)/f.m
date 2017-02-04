function[outt] = f(x,y,k)
exp = (-17).*x - rem((y+k),17); %exponent prt

frac = floor((y+k)./17);  %fraction part

in1 = frac .*2.^exp;  % number part

outt = floor(rem(in1,2));   %rounds down and removes remainder/ everything together

end
