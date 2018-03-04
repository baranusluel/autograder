%% Plot: Class Containing Data for a Plot
%
% Holds data needed for each plot in fields. 
%
% Has methods to check if a student's plot matches the solution, and to
% give feedback for the student plot. 
%
%%% Fields
% * title: The title used for the plot
%
% * xData: A cell array of vectors that represents all XData points plotted for this plot
%
% * yData: A cell array of vectors that represents all YData points plotted for this plot
%
% * zData: A cell array of vectors that represents all ZData points plotted for this plot
%
% * image: An image taken of the plot, as an MxNx3 uint8 array.
%
% * legend: A string array of all the names in the legend
%
% * colors: A string array that represents the color used for every line
%
%%% Methods
%
% * Plot
%
% * equals
%
% * generateFeedback
%
%%% Remarks
%
% TBD
%
classdef Plot
    properties (Access = public)
        title;
        xData;
        yData;
        zData;
        image;
        legend;
        colors;
    end
    methods
        %% Constructor: Instantiates a Plot
        %
        % Creates an instance of the Plot class from the student's
        % submission path.
        %
        % this = Plot(TITLE,XDATA,YDATA,ZDATA,IMAGE,LEGEND,COLORS) returns an instance of Plot. 
        % TITLE should be a string representing the title of the plot.
        % XDATA should be a cell array of vectors representing all the
        % XData points for the plot. YDATA should be a cell array of 
        % vectors representing all the YData points for the plot. ZDATA
        % should be a cell array of vectors representing all the ZData
        % points for the plot. IMAGE should be an image taken of the plot,
        % as an MxNx3 uint8 array. LEGEND should be a string array of all
        % the names in the legend. COLORS should be a string array of that
        % represents the color used for every line. 
        %
        %%% Remarks
        %
        %
        %%% Exceptions
        %
        %
        %%% Unit Tests
        %
        %
        function this = Plot(TITLE,XDATA,YDATA,ZDATA,IMAGE,LEGEND,COLORS)
            this.title = TITLE;
            this.xData = XDATA;
            this.yData = YDATA;
            this.zData = ZDATA;
            this.image = IMAGE;
            this.legend = LEGEND;
            this.colors = COLORS;
        end
    end
    methods (Access=public)
        %% equals: Checks if the given plot is equal to this plot
        %
        %
