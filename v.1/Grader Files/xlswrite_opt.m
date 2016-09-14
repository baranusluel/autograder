%% XLSWRITE OPTIMIZATION
% xlswrite(file_name, varargin)
%
% Inputs:
%   1. file_name - char vector (string) or cell array of strings - a
%	   list of file names that should be converted the Grader supported
%	   file format
%	2. varargin - various input argumments
% Outputs:
%   1. variable number of arguments
%
% Description:
%   The xlswrite optimization function simulates excel writing using a mat
%	file to store the raw data.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = xlswrite(file_name, varargin)

% Patch to account for matlab not needing a '.xls' extension
if ~any(file_name == '.')
    file_name = [file_name, '.xls'];
end
% Convert . to _ and load .mat file.
file_name(file_name == '.') = '_';
mat_file = [file_name, '.mat'];

% raw data
raw = varargin{1};

% Students like to do some odd things. If they choose to do something
% strange, call the formal version of xlswrite.
if nargin > 2 || ~iscell(raw) || exist(mat_file, 'file')
    raw = SuperXLSWrite(mat_file, varargin{1:nargin-1});
end

% Nested loops edited in by John McGrael, to account for NaN's in the
% file being written to excel.


s = size(raw);
if iscell(raw)
for i = 1:s(1)
    for j = 1:s(2)
        if isnan(raw{i,j})
            raw{i,j} = 0;
        end
    end
end
end

% Save .mat file.
save(mat_file, 'raw');

% Optional outputs.
if nargout >= 1
    varargout{1} = true;
end
if nargout >= 2
    varargout{2} = 'success';
end
end


% Changes up a directory to call formal version of xlswrite.
function raw = SuperXLSWrite(file, varargin)

% Preserve current directory.
curDir = cd;
cd ..

ME = [];

try
    
    % If the file has already been written, just update it.
    if exist([curDir '/' file], 'file')
        load([curDir '/' file]);
        xlswrite('temp.xls', raw)
    end
    
    % Write a temporary excel file, and read in its raw data.
    xlswrite('temp.xls', varargin{1:nargin-1});
    [~, ~, raw] = xlsread('temp.xls');
    delete('temp.xls');
catch ME
end

% Go back to submission attachments directory.
cd(curDir)

if ~isempty(ME)
    error(ME.message);
end
end








