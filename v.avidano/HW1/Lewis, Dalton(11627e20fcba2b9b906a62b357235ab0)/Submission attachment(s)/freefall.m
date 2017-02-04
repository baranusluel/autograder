function [out1, out2] = freefall(t)
% Determine position (out1) and velocity (out2) of an object free-falling
% from rest
% Usage:    function [out1, out2] = freefall(t)

    a= 9.807;
% Constant Variable (Acceleration)

    out_1= (a .* (t .^ 2)) ./2;

    out_2= a .* t;


    out1= round(out_1, 3);
    out2= round(out_2, 3);
%Round both velocity and position to thousandths place
end


