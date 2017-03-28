function z = notInfinteLoop
x = rand(1,10000);
y = x .* 200;
z = rand(1000,1) * y;
end