function [ given , wasted ] = candy( pieces , kids )
given = floor(pieces ./ kids );
wasted = floor(mod( pieces, kids));
end

