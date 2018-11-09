%% Segment: A single connection between two points
%
% A single connection between two points without marker!
%
%%% Fields
%
% * Start: A Point that represents where this segment starts
%
% * Stop: A Point that represents where this segment ends
%
% * Color: A 1x3 vector that represents the color
%
% * Style: A character vector that represents the style (i.e., dashed.
% etc.)
%
%%% Methods
%
% * Segment
%
% * equals
%
% * dataEquals
%
%%% Remarks
%
% This class keeps data for a single segment - a connection. It does not
% care about what the endpoints look like - only where they are.
%
% The Point will not have a style - just coordinates
%
classdef Segment < handle
    properties (Access = public)
        Start;
        Stop;
        Color double;
        Style char;
    end
    
    methods
        %% Constructor
        %
        % Segment(S, E, C, L) will use start S and stop E to make a
        % segment, with color C and line style L.
        %
        %%% Remarks
        %
        % S and E can be Points or coordinates - if the latter, they will
        % be constructed into points
        function this = Segment(start, stop, color, style)
            if nargin == 0
                return;
            end
            if isa(start, 'Point')
                this.Start = start;
                this.Stop = stop;
            else
                this.Start = Point(start);
                this.Stop = Point(stop);
            end
            this.Color = color;
            if strcmp(style, 'none')
                this.Style = '';
            else
                this.Style = style;
            end
        end
    end
    methods (Access = public)
        function tf = equals(this, that)
            tf = this.dataEquals(that) ...
                && strcmp(this.Color, that.Color) ...
                && strcmp(this.Style, that.Style);
        end
        
        function tf = dataEquals(this, that)
           tf = (this.Start.equals(that.Start) ...
               && this.Stop.equals(that.Stop)) ...
               || ...
               (this.Start.equals(that.Stop) ...
               && this.Stop.equals(that.Start));
        end
    end
end
%% Plot: Class Containing Data for a Plot
%
% Holds data needed for each plot in fields.
%
% Has methods to check if a student's plot matches the solution, and to
% give feedback for the student plot.
%
%%% Fields
%
% * Segments: A structure array of all the segments in the plot
%
% * Points: A structure array of all the points in the plot
%
% * Title: A String of the title used for the plot
%
% * XLabel: A String of the xLabel used for the plot
%
% * YLabel: A String of the yLabel used for the plot
%
% * ZLabel: A String of the zLabel used for the plot
%
% * Position: A 1X4 double vector of the position of the axes in the figure
% window
%
% * PlotBox: A 1X3 vector representing the relative axis scale factors
%
% * Image: An image taken of the plot, as an MxNx3 uint8 array.
%
% * Legend: A string array of all the names in the legend
%
% * Limits: A 1x6 double vector representing the axes limits
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
% The Plot class keeps all relevant data about a specific plot; note that
% a subplot is considered a single plot. Like the File class, the Plot
% class copies over any data necessary to recreate the plot entirely; as
% such, the plot can be deleted once a Plot object is created!
%