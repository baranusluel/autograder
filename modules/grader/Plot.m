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
% The Plot class keeps all relevant data about a specific plot; note that 
% a subplot is considered a single plot. Like the File class, the Plot 
% class copies over any data necessary to recreate the plot entirely; as 
% such, the plot can be deleted once a Plot object is created!
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
        function [areEqual, message] = equals(this, that)
            
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