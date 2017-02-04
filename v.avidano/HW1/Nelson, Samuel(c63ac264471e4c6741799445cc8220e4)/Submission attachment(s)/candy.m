function [ perkid , wasted ] = candy (bagcandy , kidnum)

    perkid = floor ( bagcandy ./ kidnum ) ;     %Number of whole pieces of candy each kid gets

    wasted = mod ( bagcandy , kidnum ) ;        %remainder of pieces of candy in the bag
    
end