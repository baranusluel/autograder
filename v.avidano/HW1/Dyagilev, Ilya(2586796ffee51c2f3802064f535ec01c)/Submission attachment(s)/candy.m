function[out1,out2] = candy(total,kids)
out2 = mod(total,kids); %calculates the leftover candy by modulo
out1 = (total-out2)./kids; % amount given to kids / kids = candy per kid
end