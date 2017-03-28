%% xlsread Overload function for xlsread
%
%   [num, txt, raw] = xlsread(filename_xls)
%
%	Input:
%       filename_xls (char)
%           - name of excel file (*.xls, *.xlsx, *.csv)
%
%   Outputs:
%       num (double)
%           - the numerical data of an excel file
%       txt (cell)
%           - the text data of an excel file
%       raw (cell)
%           - the raw data of an excel file
%
%   Description:
%       The xlsread overload function reads the excel data from a pre-saved
%       .mat file of the data.
function [varargout] = xlsread(filename_xls)

    [filename_mat,extension] = strtok(filename_xls,'.');
    filename_mat = [filename_mat '_' extension(2:end) '.mat'];

    load(filename_mat);
    
    varargout{1} = num;
    varargout{2} = txt;
    varargout{3} = raw;

end