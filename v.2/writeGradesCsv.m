%% writeGradesCsv Write grades to grades.csv
%
%   writeGradesCsv(hwDirectory,gradebook,gradesCsv)
%
%   Input(s):
%       gradebook (struct)
%           - a structure containing the students
%       gradesCsv (cell)
%           - the content to write to grades.csv
%           - enter [] or omit if you just want to update the grades from 
%           the gradebook
%
%   Output(s):
%       NONE
%
%   Description:
%       Takes gradebook struct and updates grades.csv with grades
function writeGradesCsv(gradebook,varargin)
    
    if nargin == 1
        gradesCsv = readGradesCsv(gradebook.filePaths.gradesCsv);
    else
        gradesCsv = varargin{1};
    end
    
    if ~isempty(gradebook)
        gradesCsv(4:end,5) = cellfun(@(x)(sprintf('%.1f', x)), {gradebook.students.grade}, 'uni', false);
    end
    
    filename = gradebook.filePaths.gradesCsv;

    % deal with first two rows
    file = sprintf('%s\n\n',strjoin(gradesCsv(1,1:2),','));
    
    % get each line
    for row = 3:size(gradesCsv,1)
        fileRow = strjoin(gradesCsv(row,:),',');
        file = [file,fileRow,sprintf('\n')]; %#ok
    end

    % write csv file
    fh = fopen(filename,'w');
    fprintf(fh,file);
    fclose(fh);

end