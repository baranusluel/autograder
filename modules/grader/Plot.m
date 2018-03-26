%% Plot: Class Containing Data for a Plot
%
% Holds data needed for each plot in fields. 
%
% Has methods to check if a student's plot matches the solution, and to
% give feedback for the student plot. 
%
%%% Fields
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
% * Image: An image taken of the plot, as an MxNx3 uint8 array.
%
% * Legend: A string array of all the names in the legend
%
% * XData: A cell array of vectors that represents all XData points plotted
% for this plot
%
% * XData: A cell array of vectors that represents all YData points plotted
% for this plot
%
% * ZData: A cell array of vectors that represents all ZData points plotted
% for this plot
% 
% * Color: A cell array containing the normalized 1X3 double vector of the
% color used for each line
%
% * Marker: A cell array containing the character uses as a marker in the
% line
%
% * LineStyle: A cell array containing the character uses as a marker in
% the line
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
%
classdef Plot < handle
    properties (Access = public)
        Title;
        XLabel;
        YLabel;
        ZLabel;
        Position;
        Image;
        Legend;
        XData;
        YData;
        ZData;
        Color;
        Marker;
        LineStyle;
    end
    methods
        %% Constructor
        %
        % Creates an instance of the Plot class from a student's plot
        % information.
        %
        % this = Plot(HANDLE) creates an instance of Plot from the given axes handle.
        %
        %%% Remarks
        %
        % This class takes in student plot information and compares it with
        % the solution plot information to return feedback for each
        % student.
        %
        % If the plot does not have a title, xlabel, ylabel, or zlabel, the
        % appropriate field will contain an empty string.
        %
        % Note that XDdata, YData, ZData, Color, LineStyle, and Marker will
        % all be cell arrays of the same size. If the plot had data or
        % specification in that dimension, that entry of the cell array
        % will have a vector or character; otherwise, it will be empty.
        % (Note that color should never be empty)
        %
        %%% Exceptions
        %
        % An AUTOGRADER:PLOT:NOAXISDATA exception will be thrown if no
        % input axis are provided
        %
        %%% Unit Tests
        %
        % Given valid axes handle
        %   this = Plot(pHandle)
        %
        %   this.Title -> 'My Plot'
        %   this.XLabel -> 'X-Axis'
        %   this.YLabel -> 'Y-Axis'
        %   this.ZLabel -> ''
        %   this.Image -> IMAGE (a uint8 array)
        %   this.Legend -> ["name1", "name2", ...]
        %   this.XData -> XDATA (a cell array of vectors)
        %   this.YData -> YDATA (a cell array of vectors)
        %   this.ZData -> ZDATA (a cell array of vectors)
        %   this.Color -> COLOR (a cell array of vectors)
        %   this.Marker -> MARKER (a cell array of charactors)
        %   this.LineStyle -> LINESTYLE (a cell array of charactors) 
        %
        % Given invalid axes handle
        %
        % Constructor threw exception
        % AUTOGRADER:PLOT:NOAXISDATA
        %
        function this = Plot(pHandle)
            
            if ~isa(pHandle,'matlab.graphics.axis.Axes')
                ME = MException('AUTOGRADER:PLOT:NOAXISDATA',...
                    'Given input to Plot Constructor is not Axes Handle');
                throw(ME)
            else
                this.Title = pHandle.Title.String;
                this.XLabel = pHandle.XLabel.String;
                this.YLabel = pHandle.YLabel.String;
                this.ZLabel = pHandle.ZLabel.String;
                
                fig = ancestor(pHandle,'Figure');
                imgstruct = getframe(fig);
                this.Image = imgstruct.cdata;
                
                this.Position = pHandle.Position;
                
                lines = allchild(pHandle);
                
                xcell = cell(1,length(lines));
                ycell = cell(1,length(lines));
                zcell = cell(1,length(lines));
                color = cell(1,length(lines));
                marker = cell(1,length(lines));
                linestyle = cell(1,length(lines));
                
                for i = 1:length(lines)
                    line = lines(i);
                    xcell(i) = {line.XData};
                    ycell(i) = {line.YData};
                    zcell(i) = {line.ZData};
                    
                    color(i) = {line.Color};
                    
                    if strcmp(line.Marker,'none')
                        marker(i) = {[]};
                    else
                        marker(i) = {line.Marker};
                    end
                    
                    if strcmp(line.LineStyle,'none')
                        linestyle(i) = {[]};
                    else
                        linestyle(i) = {line.LineStyle};
                    end
                end
                
                this.XData = xcell;
                this.YData = ycell;
                this.ZData = zcell;
                this.Color = color;
                this.Marker = marker;
                this.LineStyle = linestyle; 
            end
            
        end
    end
    methods (Access=public)
        %% equals: Checks if the given plot is equal to this plot
        %
        % equals is used to check a student plot against the solution plot.
        % 
        % [OK, MSG] = equals(PLOT) takes in a valid PLOT class and evaluates the plot
        % against the solution file and returns a boolean true/false stored in OK and a
        % string stored in MSG if the two plots do not match. 
        %
        %%% Remarks
        %
        % This function will compare the two plots and return a boolean
        % value.
        %
        % The message will be empty if the plots are equal.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:PLOT:EQUALS:NOPLOT exception will be thrown if inputs
        % are not of type Plot.
        %
        %%% Unit Tests
        %
        % Given that PLOT is a valid instance of Plot equal to this.
        % Given that this is a valid instance of Plot.
        %   [OK, MSG] = this.equals(PLOT)
        %
        %   OK -> true
        %   MSG -> ''
        %
        % Given that PLOT is a valid instance of Plot not equal to this.
        % Given that this is a valid instance of Plot.
        %   [OK, MSG] = this.equals(PLOT)
        %
        %   OK -> false
        %   MSG -> 'Reason for inconsistency between plots'
        %
        % Given that PLOT is not a valid instance of Plot.
        % Given that this is a valid instance of Plot.
        %   [OK, MSG] = equals(this, PLOT)
        %
        %   equals threw an exception
        %   AUTOGRADER:PLOT:EQUALS:NOPLOT
        %
        function [areEqual, message] = equals(this,that)
            TitleCheck = strcmp(this.Title,that.Title)... 
                | (isempty(this.Title) & isempty(that.Title));
            XLabelCheck = strcmp(this.XLabel,that.XLabel)... 
                | (isempty(this.XLabel) & isempty(that.XLabel));
            YLabelCheck = strcmp(this.YLabel,that.YLabel)... 
                | (isempty(this.YLabel) & isempty(that.YLabel));
            ZLabelCheck = strcmp(this.ZLabel,that.ZLabel)... 
                | (isempty(this.ZLabel) & isempty(that.ZLabel));
            
            
            PositionCheck = isequal(this.Position,that.Position);
            
            ImageCheck = isequal(this.Image,that.Image);
%             LegendCheck = ;
            
            XDataCheck = isequal(this.XData,that.XData);
            
            YDataCheck = isequal(this.YData,that.YData);
            
            ZDataCheck = isequal(this.ZData,that.ZData);
            
            
            ColorCheck = isequal(this.Color,that.Color);
            MarkerCheck = strcmp(this.Marker,that.Marker)... 
                | (isempty(this.Marker{1}) & isempty(that.Marker{1}));
            LineStyleCheck = strcmp(this.LineStyle,that.LineStyle)... 
                | (isempty(this.LineStyle{1}) & isempty(that.LineStyle{1}));
            
            
            
            areEqual = TitleCheck & XLabelCheck & YLabelCheck &...
                ZLabelCheck & PositionCheck & ImageCheck &... % LegendCheck &...
                XDataCheck & YDataCheck & ZDataCheck & ColorCheck & ...
                MarkerCheck & LineStyleCheck;
            
            
            message = '';
        end
        %% generateFeedback: Generates HTML feedback for the student and solution Plot.
        %
        % generateFeedback will return the feedback for the student's plot. 
        %
        % [HTML] = generateFeedback(PLOT) will return a character vector in HTML that contains the 
        % markup for HTML. The contents of this vector will be the feedback associated with a student's
        % plot.
        %
        %%% Remarks
        %
        % This function will output a character after calling the generateFeedback method with input as 
        % the student plot submission and the solution plot.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:PLOT:GENERATEFEEDBACK:MISSINGPLOT exception will be thrown if the student or 
        % solution plots are missing from the generateFeedback method call. 
        %
        %%% Unit Tests
        %
        % When called, the generateFeedback method will check the student Plot against the solution Plot.
        % If the student plot matches the solution plot, the character HTML vector will contain both the 
        % solution and student plot. It will also contain confirmation that the plot was correct.
        %
        % If the student plot does not matches the solution plot, the character HTML vector will contain both the 
        % solution and student plot. It will also contain a description of why the student plot is not correct,
        % referencing the solution plot as needed.
        %
        % An AUTOGRADER:PLOT:GENERATEFEEDBACK:MISSINGPLOT exception will be thrown if generateFeedback is called
        % with only one or no input Plots. 
        %
        function [html] = generateFeedback(this, that)
            
        end
    end
end