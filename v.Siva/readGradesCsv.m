%% readGradesCsv Reads the grades.csv file
%
%   gradebookTemplate = readGradesCsv(gradesCsvFilePath)
%
%   Input:
%       gradesCsvFilePath (char)
%           - path to the grades.csv file
%
%   Output:
%       gradebookTemplate (cell)
%           - cell array representation of grades.csv
%
%   Description:
%       Reads grades.csv and returns a cell array representation
function gradebookTemplate = readGradesCsv(gradesCsvFilePath)
    gradebook_fid = fopen(gradesCsvFilePath,'r');
    gradebookFile = textscan(gradebook_fid, '%s %s %s %s %s', 'Delimiter', ',');
    fclose(gradebook_fid);
    gradebookTemplate = [gradebookFile{:}];
    gradebookTemplate = [gradebookTemplate(1,:); {'','','','',''}; gradebookTemplate(2:end,:)];
end