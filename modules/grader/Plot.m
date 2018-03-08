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
classdef Plot < handle
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
        % Note that xDdata, yData, and zData will all be cell arrays of the same size.
        % If the plot had data in that dimension, that entry of the cell array will have a vector;
        % otherwise, it will be empty.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:PLOT:NOAXISDATA exception will be thrown if no input axis are
        % provided
        %
        %%% Unit Tests
        %
        % Given valid axes handle
        %   this = Plot(pHandle)
        %
        %   this.title -> 'My Plot'
        %   this.xData -> XDATA (a cell array of vectors)
        %   this.yData -> YDATA (a cell array of vectors)
        %   this.zData -> ZDATA (a cell array of vectors)
        %   this.image -> IMAGE (a uint8 array)
        %   this.legend -> ["name1", "name2", ...]
        %   this.colors -> ["color1", "color2", ...]
        %
        % Given invalid axes handle
        %
        % Constructor threw exception
        % AUTOGRADER:PLOT:NOAXISDATA
        %
        function this = Plot(pHandle)
            
        end
    end
    methods (Access=public)
        %% equals: Checks if the given plot is equal to this plot
        %
        % equals is used to check a student plot against the solution plot.
        % 
        % [check, message] = equals(PLOT) takes in a valid PLOT class and evaluates the plot
        % against the solution file and returns a boolean true/false stored in check and a
        % string stored in message if the two plots do not match. 
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
        % are not of type Plot, or only one input is given.
        %
        %%% Unit Tests
        %
        % Given that PLOT is a valid instance of Plot equal to this.
        % Given that this is a valid instance of Plot.
        % [check, message] = this.equals(PLOT)
        %
        % check -> true
        % message -> ''
        %
        % Given that PLOT is a valid instance of Plot not equal to this.
        % Given that this is a valid instance of Plot.
        % [check, message] = this.equals(PLOT)
        %
        % check -> false
        % message -> 'Reason for inconsistency between plots'
        %
        % Given that PLOT is not a valid instance of Plot.
        % Given that this is a valid instance of Plot.
        % [check, message] = equals(this, PLOT)
        %
        % equals threw an exception
        % AUTOGRADER:PLOT:EQUALS:NOPLOT
        %
        % [check, message] = equals(this)
        %
        % equals threw an exception
        % AUTOGRADER:PLOT:EQUALS:NOPLOT
        %
        function equals(this, that)
            
        end
    end
    methods (Access=public)
        %%generateFeedback: Generates HTML feedback for the student and solution Plot.
        %
        %generateFeedback will return the feedback for the student's plot. 
        %
        %[HTML] = generateFeedback(PLOT) will return a character vector in HTML that contains the 
        %markup for HTML. The contents of this vector will be the feedback associated with a student's
        %plot.
        %
        %%% Remarks
        %
        % This function will 
    end
    
end