function[out1, out2] = candy(c, k)
% Determine the pieces of candy per kid (c) and the pieces of candy
% wasted (k)
% Usage:    function[out1, out2] = candy(c, k)

    out_1= c ./k;
    out1= floor(out_1);
    out2= mod(c,k);

end

