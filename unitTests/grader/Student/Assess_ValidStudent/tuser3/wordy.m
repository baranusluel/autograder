function str = wordy(int)
str = ['1 2 3 4' num2str(int)];
fid = fopen('helloWorld.txt', 'wt');
fprintf(fid, 'Hello!');
fclose(fid);
plot(1:100, 1:100, 'b--');
end