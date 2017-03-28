function [pf, vf] = freefall(time)
    a = 9.807;
    pf = round((a.*time.^2)./2,3);
    vf = round(a.*time,3);
end