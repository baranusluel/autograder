%% runTestCase Runs the given test case
%
%   output = runTestCase(functionHandle, testCase, inputs)
%
%   Inputs:
%       functionHandle (function_handle)
%           - a function handle for the function to run the test case on
%       testCase (struct)
%           - a struct containing the information to run the test case
%           (input variables, output variables, etc.)
%       inputs (struct)
%           - a struct that resulted from the loading a .mat file
%           containing the values for the input variables for the test
%           cases
%       isSolution (logical)
%           - optional input for whether the solution or a student
%           submission is being run
%       timeout (double)
%           - optional input for how long to run the test case
%
%   Output:
%       output (struct)
%           - a struct containing the output variables, output files, and
%           any errors that may have occurred
%       testCasesTimedOut (cell) - CURRENTLY NOT SUPPORTED
%           - a cell array containing the test cases on which 
%
%   Description:
%       Runs the test case and returns the output variables, files, and
%       errors
function [output] = runTestCase(functionHandle, testCase, inputs, varargin)

    if nargin > 3
        isSolution = varargin{1};
    else
        isSolution = false;
    end

    if nargin > 4
        timeout = varargin{2};
    else
        timeout = 30;
    end

    if nargin > 5
        overridenFunctionsFolderPath = varargin{3};
    else
        overridenFunctionsFolderPath = '';
    end

    % initialize output
    output = struct('variables', [],...
                    'files'    , [],...
                    'plots'    , struct([]),...
                    'errors'   , [],...
                    'isTimeout', false);

    functionInputs = cell(1, length(testCase.inputVariables));
    for ndxInput = 1:length(testCase.inputVariables)
        functionInputs{ndxInput} = inputs.(testCase.inputVariables{ndxInput});
    end

    directoryContents = getDirectoryContents(pwd, false, true);

    close all;
    figure('Visible', 'Off');

    % add overridenFunctions to the MATLAB path before grading
    addpath(overridenFunctionsFolderPath);
    if isSolution
        % start timer
        tic

        [output.variables{1:length(testCase.outputVariables)}] = feval(functionHandle, functionInputs{:});

        % set time elapsed
        output.timeElapsed = toc;
    else
        try
            % create parallel function eval job
            f = parfeval(gcp(), functionHandle, length(testCase.outputVariables), functionInputs{:});

            % fetch outputs from job with timeout cutoff
            [f_ndx, output.variables{1:length(testCase.outputVariables)}] = fetchNext(f, timeout);

            % cancel job when done
            cancel(f);

            % if timeout was exceeded, f_ndx will be empty
            if isempty(f_ndx)
%                 output.isTimeout = true;
%                 return;
                messages = getMessages();
                poolobj = gcp('nocreate');
                delete(poolobj);
                error(messages.errors.infiniteLoop);
            end
        catch ME
            output.errors = ME;
        end
    end
    % remove overridenFunctions folder from MATLAB path
    rmpath(overridenFunctionsFolderPath);

    figureHandle = gcf;

    newDirectoryContents = getDirectoryContents(pwd, false, true);

    outputFiles = setdiff({newDirectoryContents.name}, {directoryContents.name});

    % get possible img format extensions
    possibleImageExtensions = imformats;
    possibleImageExtensions = [possibleImageExtensions.ext];

    % get files
    for ndxOutputFile = 1:length(outputFiles)
        outputFile = outputFiles{ndxOutputFile};
        [~, ~, extension] = fileparts(outputFile);
        extension         = strtok(extension,'.');

        output.files(ndxOutputFile).fileType = extension;
        output.files(ndxOutputFile).name = outputFile;

        switch extension
            case {'xls','xlsx'}
                [~, ~, raw] =  xlsread(outputFile);
                output.files(ndxOutputFile).value = raw;
            case possibleImageExtensions
                img = imread(outputFile);
                output.files(ndxOutputFile).value = img;
            case {'txt', 'm'}
                % I think this could potentially be MUCH more efficient:
                % file = textscan(fh, '%s', 'Delimiter', '\n');
                % file = strjoin(file{1}', '\n');
                fh = fopen(outputFile, 'r');
                % I think this could potentially be MUCH more efficient:
                % file = textscan(fh, '%s', 'Delimiter', '\n');
                % file = strjoin(file{1}', '\n');
                file = '';
                line = fgetl(fh);
                while ischar(line)
                    file = [file, line]; %#ok
                    line = fgetl(fh);
                    if ischar(line)
                        file = [file, sprintf('\n')]; %#ok
                    end
                end
                fclose(fh);
                output.files(ndxOutputFile).value = file;
        end

    end

    % get plots
    plots = get(figureHandle, 'Children');
    for ndxPlot = 1:length(plots)
        try
            output.plots(ndxPlot).properties.XData   = get(get(plots(ndxPlot),'Children'),'XData');
            output.plots(ndxPlot).properties.YData   = get(get(plots(ndxPlot),'Children'),'YData');
            output.plots(ndxPlot).properties.ZData   = get(get(plots(ndxPlot),'Children'),'ZData');
            output.plots(ndxPlot).properties.XLabels = get(get(plots(ndxPlot),'XLabel'), 'String');
            output.plots(ndxPlot).properties.YLabels = get(get(plots(ndxPlot),'YLabel'), 'String');
            output.plots(ndxPlot).properties.ZLabels = get(get(plots(ndxPlot),'ZLabel'), 'String');
            output.plots(ndxPlot).properties.Colors  = get(get(plots(ndxPlot),'Children'),'Color');
            output.plots(ndxPlot).properties.Marker  = get(get(plots(ndxPlot),'Children'),'Marker');
            output.plots(ndxPlot).properties.Title   = get(get(plots(ndxPlot),'Title'),'String');
            
        catch ME %#ok<NASGU>
        end
        output.plots(ndxPlot).image = base64img(figureHandle);
    end
        
    close(figureHandle);
end