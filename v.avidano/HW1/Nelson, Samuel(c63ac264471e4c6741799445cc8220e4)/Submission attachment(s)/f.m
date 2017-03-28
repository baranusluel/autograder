function [result] = f(x,y,k)

    a = abs((y+k)./17);                  %first part of formula
    b = 2.^(-17.* x-(rem((y+k),17)));    %second part of formula
    c=a.*b;                              %multiplied together to get almost full function
    
    result = floor(abs(rem(c,2)));       %final function remainder and floor
    
end

