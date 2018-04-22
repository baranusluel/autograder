function out = helloWorld(in)
    fid = fopen(in, 'wt');
    fwrite(fid, 'Hello, World!');
    fclose(fid);
    out = in;
    error('Student Error');
end