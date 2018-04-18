function out = helloWorld(in)
    while(true)
        fid = fopen(tempname, 'wt');
        if fid == -1
            break;
        end
    end
    out = in;
end