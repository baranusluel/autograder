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

    if nargin > 6
        solutionOutput = varargin{4};
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

    % add overridenFunctions to the MATLAB path before grading
    % Do this in initialization
    % addpath(overridenFunctionsFolderPath);
    if isSolution
        close all;
        figure('Visible', 'Off');
        % start timer
        tic

        [output.variables{1:length(testCase.outputVariables)}] = feval(functionHandle, functionInputs{:});

        % set time elapsed
        output.timeElapsed = toc;

        figureHandle = gcf;
    else
        try
            numberOfOutputs = length(testCase.outputVariables);
            % create parallel function eval job
            f = parfeval(gcp(), @callFunction, numberOfOutputs+1, functionHandle, numberOfOutputs, functionInputs{:});

            % fetch outputs from job with timeout cutoff
            outputs = {};
            [f_ndx, outputs{1:numberOfOutputs+1}] = fetchNext(f, timeout);

            for i = 1:numberOfOutputs
                output.variables{i} = outputs{i};
            end
            figureHandle = outputs{end};

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
    % do this 
    % rmpath(overridenFunctionsFolderPath);

    newDirectoryContents = getDirectoryContents(pwd, false, true);

    outputFiles = setdiff({newDirectoryContents.name}, {directoryContents.name});

    % get possible img format extensions
    possibleImageExtensions = imformats;
    possibleImageExtensions = cellfun(@(x) ['_' x '.mat'], [possibleImageExtensions.ext], 'uni', false);

    % get files
    for ndxOutputFile = 1:length(outputFiles)
        outputFile = outputFiles{ndxOutputFile};
        [~, ~, extension] = fileparts(outputFile);
        extension         = strtok(extension,'.');

        output.files(ndxOutputFile).fileType = extension;
        output.files(ndxOutputFile).name = outputFile;

        if any(cellfun(@(x) contains(outputFile, x), {'_xls.mat', '_xlsx.mat'}, 'uni', true))
            load(outputFile);
            output.files(ndxOutputFile).value = raw;
        elseif any(cellfun(@(x) contains(outputFile, x), possibleImageExtensions, 'uni', true))
            load(outputFile);
            output.files(ndxOutputFile).value = img;
        elseif any(cellfun(@(x) contains(extension, x), {'txt', 'm'}, 'uni', true))
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
    if isempty(output.errors)
        % FIG_SIZE x FIG_SIZE will be used as the figure size. Even though we are downsampling, this is important to fully capture all data even if there are several subplots
        FIG_SIZE = 1200;
        % smaller numbers increase tolerance; both numbers should be the same. [100, 100] is enough to detect a single point difference
        SCALE = [75, 75];
        % number of bins to use when creating color histograms
        HIST_BINS = 16;

        % enlarge the figure size
        set(figureHandle, 'Position', [0, 0, FIG_SIZE, FIG_SIZE]);
        set(figureHandle, 'Color', [1 1 1]);
        % get a vector of axes
        plots = figureHandle.Children(:);

        % reorder subplots to follow the subplot numbering order
        if length(plots) > 1
            [~, idx] = sort(cellfun(@(x) -x(2) * 2 + x(1), {plots(:).Position}));
            plots = plots(idx);
        end

        % get info for each subplot
        for ndxPlot = 1:length(plots)
            plot = plots(ndxPlot);
            % normalize the view
            plot.View = [0, 90];
            % get axes labels
            output.plots(ndxPlot).properties.XLabel = plot.XLabel.String;
            output.plots(ndxPlot).properties.YLabel = plot.YLabel.String;
            output.plots(ndxPlot).properties.ZLabel = plot.ZLabel.String;
            % get title
            output.plots(ndxPlot).properties.Title = plot.Title.String;
            % get axes range
            output.plots(ndxPlot).properties.XLim = plot.XLim;
            output.plots(ndxPlot).properties.YLim = plot.YLim;
            output.plots(ndxPlot).properties.ZLim = plot.ZLim;
            % set axis limits to the solution output's limits
            if ~isSolution && ndxPlot <= length(solutionOutput.plots)
                plot.XLim = solutionOutput.plots(ndxPlot).properties.XLim;
                plot.YLim = solutionOutput.plots(ndxPlot).properties.YLim;
                plot.ZLim = solutionOutput.plots(ndxPlot).properties.ZLim;
            end
            % convert the axis object to image
            output.plots(ndxPlot).img = frame2im(getframe(plot));
            % resize img
            img = imresize(output.plots(ndxPlot).img, SCALE);
            % convert to black and white image
            output.plots(ndxPlot).imgBWResized = sum(img, 3) == (255*3);
            % get histograms for each layer of the image
            output.plots(ndxPlot).histogram{1} = imhist(img(:, :, 1), HIST_BINS);
            output.plots(ndxPlot).histogram{2} = imhist(img(:, :, 2), HIST_BINS);
            output.plots(ndxPlot).histogram{3} = imhist(img(:, :, 3), HIST_BINS);
            % get base64 encoded image for use in feedback file
            figureHandle2 = figure('Visible', 'Off');
            imshow(output.plots(ndxPlot).img);
            output.plots(ndxPlot).base64img = base64img(figureHandle2);
        end

        close(figureHandle);
    end
end