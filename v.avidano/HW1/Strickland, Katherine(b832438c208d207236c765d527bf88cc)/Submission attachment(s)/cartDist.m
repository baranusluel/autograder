function [Dist] = cartDist (xone,yone,xtwo,ytwo)
Dist = sqrt((xtwo-xone)^2 + (ytwo-yone)^2) %to find distance
Dist = round(Dist,2) %to round to hundredths
end