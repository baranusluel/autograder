function[pos, velf] = freefall(time)

% currently gives three decimal places of value, and an extra 0. 
a = 9.807;
t = time .^2;
x = a .*t ./2;
y = a .*time;
pos = round(x, 3);
velf = round(y, 3);

end
