%% checkPlots compares the plot output of student and solution functions for equivalance
%
%   [same, details] = checkPlots(funcName, funcInputs ... )
%
%   Inputs:
%       (char) funcName: The name of the function you wish to check, as a
%           string (do NOT include '_soln')
%       (variable) funcInputs: The remaining inputs to this function are the
%           inputs that you would normally pass into the function that you
%           are checking
%
%   Outputs:
%       (logical) same: Whether or not your function produced a plot that is
%           visually the same as the solution function
%       (char) details: A string describing the differences (if any) that were
%           found between the plots
%
%   Example:
%       If you have a function called "testFunc" and the following test case:
%
%           testFunc(30, true, {'cats', 'dogs'})
%
%       Then to check the plot produced by "testFunc" against the solution
%       function "testFunc_soln" for this test case you would run:
%
%           checkPlots('testFunc', 30, true, {'cats', 'dogs'})
%
%
%   Notes:
%       Some things to watch out for that the plot checker occasionally has
%       difficulty identifying:
%
%       1.  Incorrect colors interfering with data comparison
%       2.  Incorrect axis ranges interfering with data comparison
%       3.  The order in which you plot overlapping elements interfering with
%           color comparison
%       4.  Small rounding errors causing axis ranges to be incorrect
%
%   Disclaimer:
%       This is the first semester we have used this function, so you will
%       likely come across cases where it does not work properly. In these
%       situations, you can run the solution function, then run your function
%       and look at the two plots. If you cannot identify ANY differences
%       between the two plots, then you will get full credit for your
%       submission. However, if you can see ANY differences between the plots,
%       your function output does not match the solution.
%
%       To make this function better in the future, if you do come across a
%       false negative or false positive, we ask that you email your solution
%       code as an attachment to smanivasagam3@gatech.edu with the subject line
%       "PLOT_CHECK_TEST_CASE". You can send multiple functions in one email if
%       you encounter a problem for multiple functions. Sending your code is
%       completely voluntary, but the more code we have to test the function on,
%       the better it will be in the future!

function [messages, points] = checkPlots(problemName, varargin)
disp('Closing all open figures ...');
close all;
disp(['Running ' problemName ]);
feval(str2func(problemName), varargin{:});
figureHandle = gcf;
[studOutput] = getPlots(figureHandle);

disp(['Running ' [problemName '_soln'] ]);
feval(str2func([problemName '_soln']), varargin{:});
figureHandle = gcf;
[solnOutput] = getPlots(figureHandle);

disp('Evaluating Plots');
[messages, points] = comparePlots(studOutput, solnOutput);
figure('units','normalized','outerposition',[0 0 1 1])
numPlots = min(length(studOutput.plots), length(solnOutput.plots));
for ii = 1:numPlots
    g = subplot(2, numPlots, ii);
    p = get(g,'position');
    p(3:4) = p(3:4).*1.2; % Increase subplot size
    p(2) = 0.55;
    
    set(g, 'position', p);

    imshow(studOutput.plots(ii).img);
    title(['Student Subplot Data ' num2str(ii)]);
    
    g = subplot(2, numPlots, ii+numPlots);
    p = get(g,'position');
    p(3:4) = p(3:4).*1.2; % Increase subplot size
    set(g, 'position', p);
    imshow(solnOutput.plots(ii).img);
    title(['Solution Subplot Data ' num2str(ii)]);
    
    if ~all(cellfun(@isempty, messages{ii}))
        disp(['Subplot ' num2str(ii) ' does not match'])
        celldisp(messages{ii});
    else
        disp(['Subplot ' num2str(ii) ' matches'])
    end
end


end
function [output] = getPlots(figureHandle)

% get plots
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

function [allMessages, points] = comparePlots(studPlot, solnPlot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grade Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The student's axis range can be off by this percent of the axis range and still be counted correct
AXIS_TOL = .2;
% DIFFERENCE_FACTOR = 300; % larger number increases tolerance. This is the number of pixels in the downsampled and filtered image that can be different
COLOR_TOL = 10; % angle in degrees by which any two histogram vectors may differ and still be considered equal
HAUSDORFF_TOL = 3; % Hausdorff distance between two plots
% go through output plots
allMessages = cell(length(studPlot.plots),1);
points = cell(size(allMessages));
numPlots = min(length(studPlot.plots), length(solnPlot.plots));
if (length(studPlot.plots) ~= length(solnPlot.plots))
    disp(['Warning! Number of subplots ' ...
        'between student and solution (' num2str(length(studPlot.plots)) ... 
        ' v.s. ' num2str(length(solnPlot.plots)) ') do not match']);
end
for ndxPlot = 1:numPlots
    studSubPlot = studPlot.plots(ndxPlot);
    solnSubPlot = solnPlot.plots(ndxPlot);

    isEqual = true(1, 9);
    outputMessages = cell(1, 9);

    % check axis labels
    if iscell(studSubPlot.properties.XLabel)
        studSubPlot.properties.XLabel = studSubPlot.properties.XLabel{1};
    end
    if iscell(studSubPlot.properties.YLabel)
        studSubPlot.properties.YLabel = studSubPlot.properties.YLabel{1};
    end
    if iscell(studSubPlot.properties.ZLabel)
        studSubPlot.properties.ZLabel = studSubPlot.properties.ZLabel{1};
    end                            
    if ~isequal(studSubPlot.properties.XLabel, solnSubPlot.properties.XLabel)
        isEqual(1) = false;
        outputMessages{1} = 'The x-axis label differs from the solution';
    end
    if ~isequal(studSubPlot.properties.YLabel, solnSubPlot.properties.YLabel)
        isEqual(2) = false;
        outputMessages{2} = 'The y-axis label differs from the solution';
    end
    if ~isequal(studSubPlot.properties.ZLabel, solnSubPlot.properties.ZLabel) 
        isEqual(3) = false;
        outputMessages{3} = 'The z-axis label differs from the solution';
    end

    % check the title
    if ~isequal(studSubPlot.properties.Title, solnSubPlot.properties.Title)
        isEqual(4) = false;
        outputMessages{4} = 'The title differs from the solution';
    end

    % check x axis range
    range = AXIS_TOL * diff(solnSubPlot.properties.XLim);
    if abs(studSubPlot.properties.XLim(1) - solnSubPlot.properties.XLim(1)) > range || abs(studSubPlot.properties.XLim(2) - solnSubPlot.properties.XLim(2)) > range
        isEqual(5) = false;
        outputMessages{5} = 'The x-axis range differs from the solution';
    end

    % check y axis range
    range = AXIS_TOL * diff(solnSubPlot.properties.YLim);
    if abs(studSubPlot.properties.YLim(1) - solnSubPlot.properties.YLim(1)) > range || abs(studSubPlot.properties.YLim(2) - solnSubPlot.properties.YLim(2)) > range
        isEqual(6) = false;
        outputMessages{6} = 'The y-axis range differs from the solution';
    end

    % check z axis range
    range = AXIS_TOL * diff(solnSubPlot.properties.ZLim);
    if abs(studSubPlot.properties.ZLim(1) - solnSubPlot.properties.ZLim(1)) > range || abs(studSubPlot.properties.ZLim(2) - solnSubPlot.properties.ZLim(2)) > range
        isEqual(7) = false;
        outputMessages{7} = 'The z-axis range differs from the solution';
    end

    % check color
    for ndxLayer = 1:length(solnSubPlot.histogram)
        studHist = studSubPlot.histogram{ndxLayer};
        solnHist = solnSubPlot.histogram{ndxLayer};
        % calculate angle between these two vectors
        th = acosd(dot(studHist, solnHist) / (norm(studHist) * norm(solnHist)));
        if th > COLOR_TOL
            isEqual(8) = false;
            outputMessages{8} = 'The colors differ from the solution';
        end
    end

    % check data visually
%     dataDifference = sum(sum(studSubPlot.imgBWResized ~= solnSubPlot.imgBWResized));
    hausdorffDiff = HausdorffDist(studSubPlot.imgBWResized , solnSubPlot.imgBWResized, 0);
    disp(['Hausdorff Distance Computed for Subplot ' num2str(ndxPlot) ' is ' num2str(hausdorffDiff,3)]);
    if hausdorfDiff > HAUSDORFF_TOL
        isEqual(9) = false;
        outputMessages{9} = 'The data values differ from the solution';
    end
    points(ndxPlot) = {isEqual};
    allMessages(ndxPlot) = {outputMessages}; 
end
end

% Source:
%   https://www.mathworks.com/matlabcentral/fileexchange/24514-base64-image-encoder
% Note:
%   Modified by the GT CS 1371 SD Team for use in the autograder
function base64string = base64img(fig, dpi)
%BASE64IMG encodes a MATLAB figure as jpeg in base64
%
% string = base64img
%  encodes the current figure (gcf) at 75-dpi resolution
% string = base64img(fig)
%  encodes the specified figure at 75-dpi resolution
% string = base64img(fig, dpi)
%  encodes the specfied figure at a given resolution
% base64img(...)
%  instead of returning the string, displays the encdoed image in the web
%  browser. Note this will only work on 32-bit windows machines.
%
% Example: put the MATLAB logo into the browser without needing an image file
%  membrane;
%  axis('off');
%  colormap(jet);
%  base64img;
%   
%
% See also: base64file, print, gcf

% Author: Michael Katz
% Copyright 2009 The MathWorks, Inc.

if nargin == 0
    %use the top figure if none specified
    fig = gcf;
end
if nargin < 2
    %use 75-dpi if none specified
    dpi = 75;
end

%the easiest way to get the figure's data in jpeg format is to save it as
%temporary jpeg and clean it up afterwards
file = [tempname '.jpg'];
print(sprintf('-f%i',fig.Number),'-djpeg',sprintf('-r%i', dpi), file);
base64string = base64file(file);
delete(file);

if nargout == 0 
    %if no output args, create a web page to display the image and show it
    s = sprintf(['<html><head><title>Matlab Figure: %i</title></head><body>'...
        '<img src="data:image/jpg;base64,%s"></body></html>'],...
        fig.Number, base64string);
    web(['text://' s]);
end 
end
function base64string = base64file(file)
%BASE64FILE encode a file in base64
%
% base64 = base64file(filename) returns the file's contents as a
%  base64-encoded string
%
% This file uses the base64 encoder from the Apache Commons Codec, 
% http://commons.apache.org/codec/ and distrubed with MATLAB under the
% Apache License http://commons.apache.org/license.html

% Copyright 2009 The MathWorks, Inc.

fid = fopen(file,'rb');
bytes = fread(fid);
fclose(fid);
encoder = org.apache.commons.codec.binary.Base64;
base64string = char(encoder.encode(bytes))';
end
