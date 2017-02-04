function [out1, out2] = freefall (time)
%out1=final positon in meters, out2=final velocity in m/s
%time in seconds
out1 = round(9.807 * time^(2)./2, 3);
out2 = round(9.807 * time, 3);
end
