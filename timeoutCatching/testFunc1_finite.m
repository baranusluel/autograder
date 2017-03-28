

function out = testFunc1(in)
if (length(dbstack) > 2 && dbstack(3).file == testFunc1.m); tic; end


i = 0
inner;

while i < 10; 
if toc > 3; error('Execution timed out after 3 seconds'); end
end

while in < 5
    a = 5;
    b = dbstack;

if toc > 3; error('Execution timed out after 3 seconds'); end
end


for i = 1:10
    for j = 1:inf
    
if toc > 3; error('Execution timed out after 3 seconds'); end
end


if toc > 3; error('Execution timed out after 3 seconds'); end
end


vec = 5;
for i = 1:1000000000000
    a = 'this is a string';
    vec = [vec rand];

        

if toc > 3; error('Execution timed out after 3 seconds'); end
end

out = 6;

if toc > 3; error('Execution timed out after 3 seconds'); end
end


function inner
b = dbstack;

if toc > 3; error('Execution timed out after 3 seconds'); end
end
