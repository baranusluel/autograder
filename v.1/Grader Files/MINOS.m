function MINOS(varargin)

% interface for selecting rubric and files
if strcmp('Yes', questdlg('Do you want to run the setup?'))
    rubric_FileName = autoGraderSetup();
else
    rubric_FileName = input('Rubric name please!: ');
end

s = warning('off', 'MATLAB:dispatcher:nameConflict');
% Remove some spacing issues from rubrics
fixRubricSpacing(rubric_FileName);

parse = false;
copy = false;
delete = false;

num = str2double(rubric_FileName(3:4));

% Assigning optional parameters if provided
switch length(varargin)
    case 1
        parse = varargin{1};
    case 2
        parse = varargin{1};
        copy = varargin{2};
    case 3
        parse = varargin{1};
        copy = varargin{2};
        delete = varargin{3};
    case 4
        parse = varargin{1};
        copy = varargin{2};
        delete = varargin{3};
end

fprintf('Start Grading...\n');
[hw_num file_names prob_weights prob_preConds file_tests file_vars file_vars_types prob_test_weights] = RubricParser(rubric_FileName);
if parse
    % Parse the specified file names for while loops and insert a break
    % command to prevent infinite while loops
    Parser(file_names);
end

% Copy the specified files
if copy
    xls2mat();
    copy_files();
end

% Grade Homeworks and return cell array of student names, and their 
% associated grades
[studentIDs final_grades] = Grader(hw_num, file_names, prob_weights, prob_preConds, file_tests, file_vars, file_vars_types, prob_test_weights);

% Write the Grade Sheet
writeGradeSheet(studentIDs, final_grades);

% Write the messages to the rubric
% writeMessage(num-2);
grade_report(rubric_FileName)

% Delete Files so T-square can manage upload
if delete
    delete_files();
end

fprintf('Grading Complete\n');

warning(s)

end

function fixRubricSpacing(filename)
fh = fopen(filename);
fh2 = fopen([filename(1:end-4) '_new.txt'],'w');
line = fgetl(fh);
while ~isnumeric(line)
    fprintf(fh2,'%s',line);
    line = fgetl(fh);
    if ~isnumeric(line)
        fprintf(fh2,'%s\n',char(13));
    end
end
fclose('all');
fh2 = fopen([filename(1:end-4) '_new.txt'],'r');
fh = fopen(filename,'w');
line = fgets(fh2);
while ~isnumeric(line)
    fprintf(fh,'%s',line);
    line = fgets(fh2);
end
fclose('all');
end
