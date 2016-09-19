%% overrideBannedFunctions Overrides banned functions for a problem
%
%   overrideBannedFunctions(bannedFunctions,problemNumber,problemName)
%
%   Inputs:
%       parentFolderPath (char)
%           - path to the folder where the banned functions folders will be created
%       bannedFunctions (cell)
%           - cell array of banned functions
%       problemNumber (double)
%           - problem number on the homework
%       problemName (char)
%           - function name of the problem
%
%   Output:
%       bannedFunctionsFolderPath (char)
%           - path containing the banned functions for a problem
%
%   Description:
%       Creates folder containing overriden versions of banned functions for a problem
function bannedFunctionsFolderPath = overrideBannedFunctions(parentFolderPath, bannedFunctions, problemNumber, problemName)
    
    dataTypes = {'@double', '@char', '@logical', '@cell', '@struct', '@uint8'};

    % check if bannedFunctions is class cell (if false, there is only one
    % banned function)
    if false == iscell(bannedFunctions) && false == isempty(bannedFunctions)
        bannedFunctions = {bannedFunctions};
    end

    % create banned functions folder
    folderName = sprintf('problem%d',problemNumber);
    bannedFunctionsFolderPath = fullfile(parentFolderPath, folderName);
    
    for ndxDataType = 1:length(dataTypes)
    
        folderPath = fullfile(bannedFunctionsFolderPath, dataTypes{ndxDataType});
        if exist(folderPath, 'dir')
            rmdir(folderPath, 's');
        end
        mkdir(folderPath);

        for ndxBannedFunction = 1:length(bannedFunctions)

            functionName = bannedFunctions{ndxBannedFunction};
            fileName = sprintf('%s.m',functionName);
            filePath = fullfile(folderPath, fileName);
            fh = fopen(filePath,'w');

            fprintf(fh,'function [varargout] = %s(varargin)\n',functionName);
            fprintf(fh,'\tstack = dbstack;\n');
            fprintf(fh,'\tfileName = ''%s.m'';\n', functionName);
            fprintf(fh,'\tif ~isempty(stack) && length(stack) > 1 && length(stack(2).file) == length(fileName) && all(stack(2).file == fileName)\n');
            fprintf(fh,'\t\terror(''The function "%s" is banned for the problem "%s"'');\n',functionName,problemName);
            fprintf(fh,'\telse\n');
            fprintf(fh,'\t\t[varargout{1:nargout}] = builtin(''%s'', varargin{1:nargin});\n', functionName);
            fprintf(fh,'\tend\n');
            fprintf(fh,'end');

            fclose(fh);

        end
        
    end
end