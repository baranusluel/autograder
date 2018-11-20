function myGlobalFunction
    global x;
    if isempty(x)
        x = 1;
    end
end