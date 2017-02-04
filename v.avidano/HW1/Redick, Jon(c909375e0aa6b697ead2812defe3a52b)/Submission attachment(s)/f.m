function [ value ] = f( x,y,k )
%f- this function describes the expression in the assigment
%   

a=y+k;
b= (a)/17;
e=rem((a),17);
g=-17.*(x);
d=(g)-(e);
c=2.^d;
v=b.*c;
w=rem(v,2);
value=floor(w);

end

