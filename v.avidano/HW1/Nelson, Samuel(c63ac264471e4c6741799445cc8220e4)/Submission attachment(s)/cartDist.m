function [distance] = cartDist (x1 , y1 , x2 , y2)

    x0 = x2 - x1 ;                          %x-coord distance
    y0 = y2 - y1 ;                          %y-coord distance
    radicand = x0 .^ 2 + y0 .^ 2 ;          %radicand calculation
    
    distance = sqrt ( radicand ) ;            %unrounded distance

    distance = round ( distance , 2) ;        %rounded distance
    
end