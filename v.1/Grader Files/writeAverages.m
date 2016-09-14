function writeAverages(grades, problems)
% Given a vector of grades and a cell array of problem titles, this
% function will write a text file containing score data for the assignment.

fh = fopen('Averages.txt', 'w');

% Find the longest problem title in order to align scores.
max = length(problems{1});
for i = 2:length(problems)
    if length(problems{i}) > max
        max = length(problems{i});
    end
end

space = max + 1;

fprintf(fh, '------Class Averages------\n\n');
for i = 1:length(grades)-1
    spaces = char(ones(1, space-length(problems{i})) * ' ');
    fprintf(fh, 'Problem %i - %s:%s%4.2f\n', i, problems{i}(1:end-2), ...
        spaces(1:end-length(num2str(i))+1), grades(i));
end

fprintf(fh, '\nOverall Assignment Average: %4.2f', grades(end));
    
fclose(fh);

end
