function final = grade_report(rubric)
% Given a rubric.txt file, this function will generate a graphical
% grade report for homework problems where the last column is the class
% average for the assignment and the other columns correspond to problem
% numbers in the grading rubric. The function also writes this data into a
% text document called Averages.txt.

students = dir('*(*)');
fprintf('\n\n')

% Use the RubricParser to get homework file names.
[~, file_names] = RubricParser(rubric);

% Initialize a cell array, wherein each cell will contains a vector of
% scores for a particular problem. The last cell will contain assignment
% scores for each student.
cA = cell(1, length(file_names)+1);

i = 1;
fprintf('\n')
while i <= length(students)
    fprintf([students(i).name '\n'])
    
    % Generate a vector of scores for a student's grade.txt file.
    scoreVec = grade_parser(students(i).name);
    
    % Ignore students who got a 0.
    if scoreVec(end) ~= 0
    
        % Update the cell array with scoreVec.
        for j = 1:length(cA)
            cA{j}(end+1) = scoreVec(j);
        end
    
    end
    
    i = i + 1;
end

% Convert the last into scores out of 1.
cA{end} = [cA{end}] / 100;

% Sum up the scores.
sums = [];
for i = 1:length(cA)
    sums = [sums sum(cA{i})];
end

% Calculate scores out of 100 percent class possible.
final = sums / length([cA{end}]) * 100;

% Alert the grader if problem average is below 40 percent.
fprintf('\n')
for i = find(final < 40)
    fprintf('More than 60 percent of students missed problem #%i.\n', i)
end
fprintf('\nWriting Averages.txt')

writeAverages(final, file_names)

fprintf('\nGrade Report Complete')
fprintf('\nPlotting Class Averages\n\n')

bar(final), title('Problem Scores out of Class Possible (%)')
xlabel('Problem #''s')

end
