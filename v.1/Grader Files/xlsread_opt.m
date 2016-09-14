%% XLSREAD OPTIMIZATION
% [num txt raw] = xlsread(file_name)
%
% Inputs:
%   1. file_name - char vector (string) or cell array of strings - a 
%	   list of file names that should be converted the Grader supported
%	   file format
% Outputs:
%   1. num - the numerical data of an excel file
%	2. txt - the text data of an excel file
%	3. raw - the raw data of an excel file
%
% Description: 
%   The xlsread optimization reads the excel data from a pre-saved mat
%	file of the data. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = xlsread(file_name, varargin)

% Patch to account for matlab not needing a '.xls' extension
if ~any(file_name == '.')
    file_name = [file_name, '.xls'];
end
% Convert . to _ and load .mat file.
file_name(file_name == '.') = '_';
load([file_name, '.mat']);

% Initialize num and txt.
num = raw;
txt = raw;

% Iterate through raw data, altering num and txt as necessary.
[r c] = size(raw);
for ndx = 1:r*c
    if ~ischar(txt{ndx}) || isempty(txt{ndx})
        txt{ndx} = '';
    end

    if ~isnumeric(num{ndx}) || isempty(num{ndx})
        num{ndx} = NaN;
    end
end

% Convert num to numeric array.
num = cell2mat(num);

% For loops to trim down num and txt.
removeThese = [];
for ndx = 1:r
    if all(strcmp(txt(ndx, :), ''))
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = r:-1:1
    if all(strcmp(txt(ndx, :), ''))
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
txt(removeThese, :) = [];

removeThese = [];
for ndx = 1:c
    if all(strcmp(txt(:, ndx), ''))
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = c:-1:1
    if all(strcmp(txt(:, ndx), ''))
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
txt(:, removeThese) = [];

removeThese = [];
for ndx = 1:r
    if all(isnan(num(ndx, :)))
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = r:-1:1
    if all(isnan(num(ndx, :)))
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
num(removeThese, :) = [];

removeThese = [];
for ndx = 1:c
    if all(isnan(num(:, ndx)))
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = c:-1:1
    if all(isnan(num(:, ndx)))
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
num(:, removeThese) = [];

removeThese = [];
for ndx = 1:r
    if isempty([raw{ndx, :}])
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = r:-1:1
    if isempty([raw{ndx, :}])
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
raw(removeThese, :) = [];

removeThese = [];
for ndx = 1:c
    if isempty([raw{:, ndx}])
        removeThese = [removeThese ndx];
    else
        break;
    end
end
for ndx = c:-1:1
    if isempty([raw{:, ndx}])
        removeThese = [removeThese ndx];
    else
        break;
    end  
end
raw(:, removeThese) = [];

% Output variables.
if nargout >= 1
	varargout{1} = num;
end
if nargout >= 2
	varargout{2} = txt;
end
if nargout >= 3
	varargout{3} = raw;
end

end
