function writeGradeSheet(studentIDs, final_grades)
disp('Writing Grade File...')
grade_fid = fopen('grades.csv', 'r');
ln1 = fgetl(grade_fid);
ln2 = fgetl(grade_fid);
ln3 = fgetl(grade_fid);
gradeFile = textscan(grade_fid, '%s %s %s %s %s', 'Delimiter', ',');
[gradeFile_students i] = sort(gradeFile{2});

for j = 1:length(gradeFile)
    gradeFile{j} = gradeFile{j}(i);
end

[studentIDs, i] = sort(studentIDs); 
final_grades = final_grades(i);


fclose(grade_fid);

grade_fid = fopen('grades.csv', 'w');
fprintf(grade_fid, '%s\n', ln1);
fprintf(grade_fid, '%s\n', ln2);
fprintf(grade_fid, '%s\n', ln3);

i = 1;
j = 1;
num_students = length(studentIDs);
while i <= num_students && j <= length(gradeFile_students)
    if strcmp(studentIDs{i},gradeFile_students{j})
        fprintf(grade_fid,'%s,%s,%s,%s,%.1f\n', gradeFile{1}{j}, ...
            gradeFile{2}{j}, gradeFile{3}{j}, gradeFile{4}{j}, final_grades(i));
        i = i + 1;
    elseif strcmp(studentIDs{i + 1},gradeFile_students{j})
        % checks for the opposite way...cuz sometimes its dumb... this is
        % only one leeway...maybe will make it better another day...
        % edit by Ankit Raghuram
        fprintf(grade_fid,'%s,%s,%s,%s,%.1f\n', gradeFile{1}{j}, ...
            gradeFile{2}{j}, gradeFile{3}{j}, gradeFile{4}{j}, final_grades(i + 1));
        i = i + 2;
    end
    j = j + 1;
end
fclose(grade_fid);

while i <= num_students
    disp(studentIDs{i});
    i = i + 1;
end
end
