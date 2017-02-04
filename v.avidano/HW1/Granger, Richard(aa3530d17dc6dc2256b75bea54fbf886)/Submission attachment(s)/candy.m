function [ candy_per_kid , candy_wasted ] = candy( sugar , brats )
%In sharing candy amongst kids, determines how many pieces of candy each
%kid gets and how many pieces are left over

candy_per_kid = floor(sugar ./ brats)
candy_wasted = mod(sugar , brats)

end