function student
    eval('1 + 2');
    a = hi();
    b = 2;
    c = parfeval(@disp, 0, b);
    d = zeros(1:5);
    parfor a = 1:5
        d(a) = 1;
    end
end