function [ candy_per_kid , candy_wasted ] = candy ( candy_per_bag , number_of_kids )
%remainder
remainder = rem(candy_per_bag , number_of_kids );
%candy per kid
candy_per_kid = ((candy_per_bag- remainder) / number_of_kids ) ;
%candy wasted
candy_wasted = remainder;
end