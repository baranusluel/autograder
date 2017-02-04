function [res1] = cartDist(x1,y1,x2,y2)
%I put the 4 variable in the funtion into the input and made the output
%res1
%usage:function [res1] = cartDist( x1,y2,x1,x2 )
%had to figure out the order of the imputs
part1 = x2-x1;
part2 = y2-y1; 
part3 = part1.^2;
part4 = part2.^2;
part5 = sqrt(part3 + part4);
res1 = round(part5 .*100)./100;
%broke the function down into the most basic parts to out together at the
%end

end

