function final = f(x,y,k) %function header
final = round(rem(((y+k)/2)*2^(-17*x-rem((y+k),17)),2)); %algorithm to solve
end %end of function