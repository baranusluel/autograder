function helloWorld()
    fid = fopen('test1_soln.txt', 'wt');
    fprintf(fid, 'Hello World');
    fclose(fid);
    fid = fopen('test2_soln.txt', 'w');
    fprintf(fid, 'Wassup World');
    fclose(fid);
end