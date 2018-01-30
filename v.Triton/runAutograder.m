function runAutograder(canvasZipPath, rubricZipPath, destinationPath, canvasGradebookPath, hwName, resub)
    
    % Retrieve Inputs if some are not given
    
    % Get a lookup Path to make things easier
    if exist('canvasZipPath', 'var')
        lookupPath = fileparts(canvasZipPath);
    elseif exist('rubricZipPath', 'var')
        lookupPath = fileparts(rubricZipPath);
    elseif exist('destinationPath', 'var')
        lookupPath = fileparts(destinationPath);
    elseif exist('canvasGradebookPath', 'var')
        lookupPath = fileparts(canvasGradebookPath);
    else
        lookupPath = '';
    end
    
    % Retrieve the Canvas submissions
    if ~exist('canvasZipPath', 'var')
        [canvasZip, canvasPath] = uigetfile([lookupPath '\*.zip'], 'Select the .zip downloaded from canvas');
        canvasZipPath = fullfile(canvasPath, canvasZip);
        lookupPath = canvasPath;
    end
    
    % Retrieve the Rubric .zip file
    if ~exist('rubricZipPath', 'var')
        [rubricZip, rubricPath] = uigetfile([lookupPath '\*.zip'], 'Select the rubric .zip');
        rubricZipPath = fullfile(rubricPath, rubricZip);
        lookupPath = rubricPath;
    end
	
    % Retrieve the destination folder
    if ~exist('destinationPath','var')
        destinationPath = uigetdir(lookupPath, 'Select the destination folder');
        lookupPath = destinationPath;
    end
    
    % Retrieve the canvas gradebook
    if ~exist('canvasGradebookPath','var')
        [canvasGradebook, gradebookPath] = uigetfile([lookupPath '\*.csv'], 'Select the gradebook .csv downloaded from canvas');
        canvasGradebookPath = fullfile(gradebookPath, canvasGradebook);
    end
    
    if ~exist('hwName','var') || ~exist('resub','var')
        f = figure('Name','Select Homework',...
                   'Visible','on',...
                   'Units','Normalized',...
                   'Position',[.4 .3 .25 .4]);
        list = uicontrol(f,'Style','listbox',...
                           'String',{'Homework 01 - Basics',...
                                     'Homework 02 - Functions',...
                                     'Homework 03 - Vectors and Strings',...
                                     'Homework 04 - Logicals and Masking',...
                                     'Homework 05 - Arrays and Images',...
                                     'Homework 06 - Conditionals',...
                                     'Homework 07 - Iteration',...
                                     'Homework 08 - Low Level I/O',...
                                     'Homework 09 - High Level I/O',...
                                     'Homework 10 - Structures',...
                                     'Homework 11 - Plotting and Numerical Methods',...
                                     'Homework 12 - Recursion',...
                                     'Homework 14 - Extra Credit'},... % Add more homeworks later as they are decided
                           'Units','Normalized',...
                           'Position',[.05 .35 .90 .60]);
        chkbx = uicontrol(f,'Style','checkbox',...
                            'String','Resubmission',...
                            'Units','Normalized',...
                            'Position',[.1 .25 .8,.1]);
        uicontrol(f,'Style','pushbutton',...
                    'String','Submit to grader',...
                    'Units','Normalized',...
                    'Position',[.25 .05 .5,.15],...
                    'Callback','uiresume(gcbf)');
        uiwait(f);
        hwName = list.String{list.Value};
        resub = logical(chkbx.Value);
        close(f)    
    end
    
    if resub
        hwName = [hwName(1:find(hwName == '-')+1) 'Resubmission'];
    end
    
    % Put individual students into individual folders with more appropriate
    %   names
    parsedCanvasPath = canvasParser(canvasZipPath, canvasGradebookPath, hwName, resub);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end