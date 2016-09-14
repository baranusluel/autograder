function vec = grade_parser(name)
% Given the file name of a student, this function will generate a vector
% of scores from the grade.txt file.

cd(name)
cd('Feedback Attachment(s)')

fh = fopen('grade.txt');

line = fgetl(fh);
vec = [];

while ischar(line)
    
    % Parse out the line.
    ndx = strfind(line, 'Problem Score: ');
    ndx2 = strfind(line, 'Final Grade: ');
    
    % Add scores to output vector.
    if ~isempty(ndx)
        vec = [vec eval(line(ndx(1)+15:end))];
    elseif ~isempty(ndx2)
        vec = [vec eval(line(ndx2(1)+13:end))];
    end
    
    line = fgetl(fh); 
end

fclose(fh);

cd(['..' filesep '..']);

end
