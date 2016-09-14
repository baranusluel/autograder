%% xlswrite Overload function for xlswrite
%
%   filename_mat = xlswrite(filename_xls,varargin)
%
%   Input:
%       filename_xls (char)
%           - name of excel file (*.xls, *.xlsx, *.csv)
%
%	Output:
%       filename_mat (char)
%           - name of mat file (.mat)
%
%   Output File:
%       mat file containing variables: num, txt, and raw
%
%   Description:
%       The xlswrite overload function simulates excel writing using a .mat
%       file to store the num, txt, and raw data.
function filename_mat = xlswrite(filename_xls,varargin)

    % get .mat filename
    [filename_mat,extension] = strtok(filename_xls,'.');
    extension(1) = [];
    filename_mat = [filename_mat '_' extension '.mat'];

    % get raw data
    raw = varargin{1};

    if nargin > 2 || ~iscell(raw)

        % call builtin xlswrite
        currentDirectory = cd;
        raw = xlswrite_builtin(currentDirectory,extension,filename_mat,varargin{1:end});

    end

    save(filename_mat,raw);

end

%% xlswrite_builtin Helper function for xlswrite overload
%
%   raw = xlswrite_builtin(returnDirectory,extension,filename_mat,varargin)
%
%   Inputs:
%       returnDirectory (char)
%           - student submission directory to return to
%       extension (char)
%           - excel file extension (.xls, .xlsx, etc.)
%       filename_mat (char)
%           - .mat filename of excel file of interest
%       varargin (cell)
%           - inputs to student's function call of xlswrite
%
%   Outputs:
%       raw (cell)
%           - raw data of student's output excel file
%
%   Description:
%       The xlswrite_builtin function is called when the student uses an
%       "unusual" format to call the builtin xlswrite function. We go to
%       the system's default temporary directory and write the excel file.
%       Then we read the file, delete it, and return the raw data.
function raw = xlswrite_builtin(returnDirectory,extension,filename_mat,varargin)

    cd(tempdir)

    try
        filename = ['temp.' extension];

        % If the file has already been written, just update it
        if exist(fullfile(returnDirectory,filename_mat),'file')

            load(fullfile(returnDirectory,filename_mat));
            builtin('xlswrite', filename, raw); %#ok

        end

        builtin('xlswrite', filename, varargin{:});
        [~,~,raw] = xlsread(filename);
        delete(filename);

    catch ME
        % do nothing because we still need to go back to the 
        % student submission attachments directory
    end

    % go back to the student submission directory
    cd(returnDirectory)

    if ~isempty(ME)
        error(ME.message);
    end

end