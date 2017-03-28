function [ pf , vf ] = freefall ( time )

    pf = ( 9.807 .* time .^ 2 ) ./ 2 ;  %unrounded position
    
    vf = ( 9.807 .* time ) ;            %unrounded velocity

    pf = round ( pf , 3 ) ;             %rounded position
    
    vf = round ( vf , 3 ) ;             %rounded velocity
    
end