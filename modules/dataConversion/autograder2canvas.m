%% autograder2Canvas: Generate Canvas files from autograder
% 
% Create the gradebook csv file used by canvas to import grades.
%
% autograder2Canvas(S, C, H) takes the graded Student Array in S and writes
% it to the CSV given by the path in C in the assignment name specified by
% H.
%
% This function will take in a graded student array (S), the name of the
% gradebook from the canvas website (C), and the name of the homework that 
% it is grading (H). H should be selected before the autograder runs and as
% such should always be valid.
%
% This function will edit the gradebook such that it has the new scores
% from the student array.
%
%%% Remarks
%
% If autograder2canvas is given an ungraded student in an array, it will
% simply pass over the student and not put a grade in the gradebook.
%
%%% Exceptions
%
% AUTOGRADER:AUTOGRADER2CANVAS:INVALIDSTUDENTS exception will be thrown if
% the function is run without a valid student array
% 
% AUTOGRADER:AUTOGRADER2CANVAS:INVALIDGRADEBOOK exception will be thrown if
% the function is run with an invalid gradebook file name.
%
% AUTOGRADER:AUTOGRADER2CANVAS:INVALIDHOMEWORKNAME exception will be thrown
% if the function is run with a hw name that is not in the gradebook.
%
%%% Unit Tests
%
%   S = [...]; % Assume valid graded Student Array
%   G = 'C:\Users\...\grades.csv'; % Valid grades.csv
%   H = 'Homework 1';
%   autograder2canvas(S, G, H);
%
%   CSV found in path G is now correctly formatted for Canvas
%
%   S = [...]; % Assume valid graded Student Array
%   G = 'C:\Users\...\grades.csv'; % Valid path, but invalid format!
%   H = 'Homework 1';
%   autograder2canvas(S, G, H);
%
%   Threw INVALIDGRADEBOOK exception
%
%   S = [...]; % Assume valid UNGRADED Student Array
%   G = 'C:\Users\...\grades.csv'; % Valid grades.csv
%   H = 'Homework 1';
%   autograder2canvas(S, G, H);
%
%   No changes were made, since Student is not graded
% 
%   S = [...]; % Graded Student array
%   G = ''; % Invalid path
%   H = 'Homework 1';
%   autograder2canvas(S, G, H);
%
%   Threw INVALIDGRADEBOOK exception
%
function autograder2canvas(studentArr,canvasGradebook,homeworkName)
    
    if ~exist('studentArr','var') || isa(studentArr,'Student')
        error('INVALIDSTUDENTS')
    end
    
    if ~exist('canvasGradebook','var') || ~contains(canvasGradebook,'.csv')
        error('INVALIDGRADEBOOK')
    end
    [~,~,gradebook] = xlsread(canvasGradebook);
    
    if ~exist('homeworkName','var') || isValidHwName(homeworkName,gradebook)
        error('INVALIDHOMEWORKNAME')
    end
    
end

function writeCsv(cellArr,fileName)
    fh = fopen(fileName,'w');
    for r = 1:canvasDimvec(1)
        fprintf(fh,'"%s"',cellArr{r,1});
        for c = 2:canvasDimvec(2)
            if isnan(cellArr{r,c})
                fprintf(fh,',');
            elseif isnumeric(cellArr{r,c})
                fprintf(fh,',%.1f',cellArr{r,c});
            elseif ischar(cellArr{r,c})
                fprintf(fh,',%s',cellArr{r,c});
            end
        end
        fprintf(fh,'\n');
    end
    fclose(fh);
end

function log = isValidHwName(hwName,gradebook)
    names = gradebook(1,6:end);
    names(~cellfun(@ischar,names)) = {''};
    log = any(strcmp(hwName,names));
end












