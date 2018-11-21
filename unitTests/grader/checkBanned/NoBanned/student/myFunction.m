function out = myFunction()
    eval = 1;
    out = 'hello';
    out = [myOtherFunction() mySecond(eval) hello()];
end

function out2 = mySecond(eval)
    out2 = eval;
end