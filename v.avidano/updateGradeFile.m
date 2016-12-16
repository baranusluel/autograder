function updateGradeFile(grades)

gradeFile = 'grades.csv';
%Get old grade info as Mx5 cell array
fid = fopen(gradeFile);
file = textscan(fid,'%s %s %s %s %s','Delimiter',',');
fclose(fid);
file = [file{:}];

%Make another file
fid = fopen(gradeFile,'w');

%Print Header Lines
fprintf(fid,'%s,%s\n\n',file{1,1:2});
fprintf(fid,'%s,%s,%s,%s,%s\n',file{2,:});

%Add in new grades
for i = 3:size(file,1)
    fprintf(fid,'%s,%s,%s, %s,%.1f\n',file{i,1:4},grades(i-2));
end

fclose(fid);

end 