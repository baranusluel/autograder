%% isGradesCsvFormatDifferent Check if the grades.csv file has a different format than expected
%
%   [isFormatDifferent,columnIndices] = isGradesCsvFormatDifferent(gradebookTemplate)
%
%   Input(s):
%       gradebookTemplate (cell)
%           - raw cell array from xlsread of the grades.csv file
%
%   Output(s):
%       isFormatDifferent (logical)
%           - logical for whether or not the format of grades.csv has
%           changed
%       columnIndices (double)
%           - the indices of the columns with the desired headers
%
%   Description:
%       Check headers and returns whether or not the grades.csv format 
%   changed
function [isFormatDifferent,columnIndices] = isGradesCsvFormatDifferent(gradebookTemplate)

    % get header row
    headers = gradebookTemplate(3,:);

    % get column masks
    displayIdColumn = strcmpi(headers,'display id');
    idColumn = strcmpi(headers,'id');
    lastNameColumn = strcmpi(headers,'last name');
    firstNameColumn = strcmpi(headers,'first name');
    gradeColumn = strcmpi(headers,'grade');

    % format is different if any columns are false
    isFormatDifferent = ~all(displayIdColumn|idColumn|lastNameColumn|firstNameColumn|gradeColumn);

    % get numerical indices values
    columnIndices = [find(displayIdColumn),find(idColumn),find(lastNameColumn),find(firstNameColumn),find(gradeColumn)];

end