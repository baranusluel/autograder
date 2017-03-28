function [perKid , wasted] = candy(pieces , kids)

%Goal is to find amoount of candy each kid will recieve and also how many
%   pieces of candy will be wasted
%Formulas used are candyperkid = pieces/kids and wasted = rem(pieces,kids)

perKid = floor(pieces ./ kids);

wasted = mod(pieces , kids);


end