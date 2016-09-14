%% lint Runs checkcode on the .m files in the directory
%
%   [] = lint()
%
%   Inputs:
%       NONE
%
%   Outputs:
%       NONE
%
%   Description:
%       Runs checkcode on the .m files in the directory excluding specified
%       files
function [] = lint()
    filesToExclude = {'base64img.m', 'loadjson.m'};
    files = getDirectoryContents(fullfile(pwd, '*.m'), false, true);
    
    clc;
    
    disp('Running lint on autograder...');
    
    isFeedbackFound = false;
    for ndxFile = 1:length(files)
        filename = files(ndxFile).name;
        if ~any(strcmp(filename, filesToExclude))
            feedback = checkcode(filename, '-string');
            if ~isempty(feedback)
                isFeedbackFound = true;
                fprintf('%s\n==================================================\n',...
                        filename);
                checkcode(filename);
            end
        end
    end
    
    if ~isFeedbackFound
        disp('No issues found');
    end
end