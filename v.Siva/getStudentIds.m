%% getStudentIds Get student ids from folder names
%
%   [studentIds,studentFolders] = getStudentIds(filePath)
%
%   Input(s): 
%       filePath (char)
%           - file path to student folders and grades.csv file
%
%   Output(s):
%       studentIds (cell)
%           - Nx1 cell array of student ids
%       studentFolders (struct)
%           - Nx1 structure array of student folders
%
%   Description:
%       Gets student ids from folder names in given directory
function [studentIds,studentFolders] = getStudentIds(filePath)
    
    % get directory content
    files = dir(filePath);

    % get mask of student folders
    isStudentFolder = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..');

    % get student folders
    studentFolders = files(isStudentFolder);

    % get cell array of student ids
    [~,studentIds] = cellfun(@(x) strtok(x,'('),{studentFolders.name},'UniformOutput',false);
    [studentIds,~] = cellfun(@(x) strtok(x,'()'),studentIds,'UniformOutput',false);

end