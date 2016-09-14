function rubricSolnCheck(rubric_FileName)
% RUBRICCHECK Parses CS 1371 Autograder rubric and prints errors
% Usage: rubricCheck(rubric_filename)

s = warning('off', 'MATLAB:dispatcher:nameConflict');
% Remove some spacing issues from rubrics
fixRubricSpacing(rubric_FileName);

fprintf('Start Rubric Check...\n');
[hw_num, file_names, prob_weights, prob_preConds, file_tests, ...
    file_vars, file_vars_types, prob_test_weights] = ...
    RubricParser(rubric_FileName);

% Grade Homeworks and return cell array of student names, and their 
% associated grades
%Grader(hw_num, file_names, prob_weights, prob_preConds, file_tests, ...
%    file_vars, file_vars_types, prob_test_weights);

fprintf('Rubric check complete!\n');

warning(s)

end

function fixRubricSpacing(filename)
fh = fopen(filename);
fh2 = fopen([filename(1:end-4) '_new.txt'],'w');
line = fgetl(fh);
while ~isnumeric(line)
    fprintf(fh2,line);
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
    fprintf(fh,line);
    line = fgets(fh2);
end
fclose('all');
end
