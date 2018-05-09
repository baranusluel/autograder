%% Plot: Class Containing Data for a Plot
%
% Holds data needed for each plot in fields.
%
% Has methods to check if a student's plot matches the solution, and to
% give feedback for the student plot.
%
%%% Fields
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
% * XData: A cell array of vectors that represents all XData points plotted
% for this plot
%
% * YData: A cell array of vectors that represents all YData points plotted
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
        PlotBox;
        Image;
        Legend;
        XData;
        YData;
        ZData;
        Color;
        Marker;
        LineStyle;
    end
    properties (Access=private)
        isAlien logical = false;
    end
    methods
        function this = Plot(pHandle)
        %% Constructor
        %
        % Creates an instance of the Plot class from a student's plot
        % information.
        %
        % this = Plot(HANDLE) creates an instance of Plot from the given
        % axes handle.
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
        % An AUTOGRADER:Plot:noAxisData exception will be thrown if no
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
            if nargin == 0
                return;
            end
            if ~isa(pHandle,'matlab.graphics.axis.Axes')
                ME = MException('AUTOGRADER:Plot:noAxisData',...
                    'Given input to Plot Constructor is not Axes Handle');
                throw(ME);
            end
            this.Title = pHandle.Title.String;
            this.XLabel = pHandle.XLabel.String;
            this.YLabel = pHandle.YLabel.String;
            this.ZLabel = pHandle.ZLabel.String;
            this.Position = pHandle.Position;
            this.PlotBox = pHandle.PlotBoxAspectRatio;
            
            tmp = figure();
            par = pHandle.Parent;
            pHandle.Parent = tmp;
            imgstruct = getframe(tmp);
            this.Image = imgstruct.cdata;
            
            pHandle.Parent = par;
            close(tmp);
            delete(tmp);

            lines = allchild(pHandle);
            if isempty(lines)
                this.XData = {};
                this.YData = {};
                this.ZData = {};
                this.Legend = {};
                this.Color = {};
                this.Marker = {};
                this.LineStyle = {};
                return;
            end
            for i = length(lines):-1:1
                if ~isa(lines(i), 'matlab.graphics.chart.primitive.Line')
                    lines(i) = [];
                    this.isAlien = true;
                end
            end
            xcell = {lines.XData};
            ycell = {lines.YData};
            zcell = {lines.ZData};
            
            % Round data to sigfig
            xcell = cellfun(@(xx)(roundData(xx)), xcell, 'uni', false);
            ycell = cellfun(@(yy)(roundData(yy)), ycell, 'uni', false);
            zcell = cellfun(@(zz)(roundData(zz)), zcell, 'uni', false);
            
            legend = {lines.DisplayName};
            color = {lines.Color};
            marker = {lines.Marker};
            marker(strcmp(marker, 'none')) = {''};
            linestyle = {lines.LineStyle};
            linestyle(strcmp(linestyle, 'none')) = {''};
            % Plot Chaining
            % A line by any other name is just as beautiful. Suppose we
            % want the student to plot a line from origin to (1, 1), then
            % from (1, 1) to (0, 2). There's two ways of doing this:
            %   plot([0 1 0], [0 1 2], 'STYLE');
            % OR
            %   plot([0 1], [0 1], 'STYLE');
            %   hold on;
            %   plot([1 0], [1 2], 'STYLE');
            % We need to handle both. How? By chaining
            %
            % For each line, search through the list for another line that
            % has these characteristics:
            %   same line style
            %   same marker
            %   same color
            %   The FIRST (x,y,z) of new one matches the LAST (x,y,z) of
            %   current choice
            % if it meets these conditions, we need to combine them and
            % then start the search over.
            % if it has NO line style, then we don't care about first
            % matching last
            % 
            % After we're done combining, if there's no line style, we need
            % to sort the data - this is because we don't care which order
            % they plotted simple points in.
            i = 1;
            while i <= numel(linestyle)
                lStyle = linestyle{i};
                mStyle = marker{i};
                cStyle = color{i};
                % if no line, then just points. Point chaining does not
                % depend on first, last.
                if isempty(lStyle)
                    lastSet = {};
                    firstSet = {};
                else
                    lastSet = getLast(xcell{i}, ycell{i}, zcell{i});
                    firstSet = getFirst(xcell{i}, ycell{i}, zcell{i});
                end
                % We now have the x, y, z data that forms the end of this
                % line. So, loop through remaining lines. If any of them
                % match AND their starting points match the ending points,
                % then engage
                j = i + 1;
                while j <= numel(linestyle)
                    if strcmp(lStyle, linestyle{j}) && ...
                            strcmp(mStyle, marker{j}) && ...
                            isequal(cStyle, color{j})
                        % possible match. If last of main line matches
                        % first of this, or other way around, engage
                        if isempty(linestyle{j})
                            % doesn't matter, just match
                            xcell{i} = [xcell{i} xcell{j}];
                            ycell{i} = [ycell{i} ycell{j}];
                            zcell{i} = [zcell{i} zcell{j}];
                        else
                            thisFirstSet = getFirst(xcell{j}, ycell{j}, zcell{j});
                            thisLastSet = getLast(xcell{j}, ycell{j}, zcell{j});
                            % don't worry about messing with i; i will
                            % always be less than j
                            if isequal(lastSet, thisFirstSet)
                                xcell{i} = [xcell{i}(1:end-1) xcell{j}];
                                ycell{i} = [ycell{i}(1:end-1) ycell{j}];
                                zcell{i} = [zcell{i}(1:end-1) zcell{j}];
                                xcell(j) = [];
                                ycell(j) = [];
                                zcell(j) = [];
                                color(j) = [];
                                legend(j) = [];
                                marker(j) = [];
                                linestyle(j) = [];
                                j = j - 1;
                            elseif isequal(thisLastSet, firstSet)
                                xcell{i} = [xcell{j}(1:end-1) xcell{i}];
                                ycell{i} = [ycell{j}(1:end-1) ycell{i}];
                                zcell{i} = [zcell{j}(1:end-1) zcell{i}];
                                xcell(j) = [];
                                ycell(j) = [];
                                zcell(j) = [];
                                color(j) = [];
                                legend(j) = [];
                                marker(j) = [];
                                linestyle(j) = [];
                                j = j - 1;
                            end
                        end
                    end
                    j = j + 1;
                end
                i = i + 1;
            end
            
            % for every line that has no line style, we should sort it.
            for l = 1:numel(linestyle)
                if isempty(linestyle{l})
                    % sort. Doesn't matter by what, but be consistent
                    pt = cell(1, 3);
                    
                    if ~isempty(xcell{l})
                        pt(1) = {arrayfun(@num2str, xcell{l}, 'uni', false)'};
                    end
                    
                    if ~isempty(ycell{l})
                        pt(2) = {arrayfun(@num2str, ycell{l}, 'uni', false)'};
                    end
                    if ~isempty(zcell{l})
                        pt(3) = {arrayfun(@num2str, zcell{l}, 'uni', false)'};
                    end
                    % pick out non empty
                    pt(cellfun(@isempty, pt)) = [];
                    % now join such that we have 1xN cell array of strings
                    pt = join([pt{:}], ' ');
                    [~, inds] = sort(pt);
                    % now we have indices; apply
                    if ~isempty(xcell{l})
                        xcell{l} = xcell{l}(inds);
                    end
                    if ~isempty(ycell{l})
                        ycell{l} = ycell{l}(inds);
                    end
                    if ~isempty(zcell{l})
                        zcell{l} = zcell{l}(inds);
                    end
                else
                    % TL;DR: reverse the order of all the points in the 
                    % line, in all three dimensions, if the student plotted
                    % in reverse and the larger values came before the 
                    % smaller ones.
                    
                    % order the line. By convention, all lines should be
                    % ordered by X Value, from least to greatest, such that
                    % the first value is always less than the last value.
                    % If they're the same, we order it such that the second
                    % value is less than the second to last value - and so
                    % on. If the X Values are all the same, then move to Y
                    % values, then to Z values. If all values are
                    % identical, then sorting doesn't really matter...
                    vals = [xcell(l), ycell(l), zcell(l)];
                    dim = 1;
                    while isempty(vals{dim})
                        dim = dim + 1;
                        if dim == 4
                            break;
                        end
                    end
                    if dim ~= 4
                        ind1 = 1;
                        ind2 = length(vals{dim});

                        val1 = vals{dim}(ind1);
                        val2 = vals{dim}(ind2);
                        while val1 == val2
                            % If they are equal, get the next val
                            ind1 = ind1 + 1;
                            ind2 = ind2 - 1;
                            if ind1 >= ind2
                                % We've reached end. Move to next value...
                                % if we've reached last dim, just exit - no
                                % need to sort since all data is identical...

                                % keep iterating through dims until we find
                                % non-empty
                                dim = dim + 1;
                                while isempty(vals{dim})
                                    dim = dim + 1;
                                    if dim == 4
                                        break;
                                    end
                                end
                                if dim == 4
                                    break;
                                else
                                    ind1 = 1;
                                    ind2 = length(vals{dim});
                                end
                            end
                            val1 = vals{dim}(ind1);
                            val2 = vals{dim}(ind2);
                        end

                        % if vals are equal, data identical; no need to do
                        % anyting
                        if val1 > val2
                            xcell{l} = xcell{l}(end:-1:1);
                            ycell{l} = ycell{l}(end:-1:1);
                            zcell{l} = zcell{l}(end:-1:1);
                        end
                    end
                end
            end
            
            this.XData = xcell;
            this.YData = ycell;
            this.ZData = zcell;
            this.Legend = legend;
            this.Color = color;
            this.Marker = marker;
            this.LineStyle = linestyle;

            function last = getLast(x, y, z)
                last = cell(1, 3);
                % depending on what we have, do different things?
                if ~isempty(x)
                    last{1} = x(end);
                end
                if ~isempty(y)
                    last{2} = y(end);
                end
                if ~isempty(z)
                    last{3} = z(end);
                end
            end
            function first = getFirst(x, y, z)
                first = cell(1, 3);
                % depending on what we have, do different things?
                if ~isempty(x)
                    first{1} = x(1);
                end
                if ~isempty(y)
                    first{2} = y(1);
                end
                if ~isempty(z)
                    first{3} = z(1);
                end
            end
        end
    end
    methods (Access=public)
        function areEqual = equals(this,that)
        %% equals: Checks if the given plot is equal to this plot
        %
        % equals is used to check a student plot against the solution plot.
        %
        % [OK, MSG] = equals(PLOT) takes in a valid PLOT class and
        % evaluates the plot against the solution file and returns a
        % boolean true/false stored in OK and a string stored in MSG if the
        % two plots do not match.
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
        % An AUTOGRADER:Plot:equals:noPlot exception will be thrown if
        % inputs are not of type Plot.
        %
        %%% Unit Tests
        %
        % Given that PLOT is a valid instance of Plot equal to this.
        % Given that this is a valid instance of Plot.
        %   [OK] = this.equals(PLOT)
        %
        %   OK -> true
        %
        % Given that PLOT is a valid instance of Plot not equal to this.
        % Given that this is a valid instance of Plot.
        %   [OK] = this.equals(PLOT)
        %
        %   OK -> false
        %
        % Given that PLOT is not a valid instance of Plot.
        % Given that this is a valid instance of Plot.
        %   [OK] = equals(this, PLOT)
        %
        %   equals threw an exception
        %   AUTOGRADER:Plot:equals:noPlot
        %
            if ~isa(that,'Plot')
                ME = MException('AUTOGRADER:Plot:equals:noPlot',...
                    'input is not a valid instance of Plot');
                throw(ME);
            end
            if this.isAlien || that.isAlien
                areEqual = false;
                return;
            end
            if ~strcmp(strjoin(cellstr(this.Title), newline), strjoin(cellstr(that.Title), newline))
                areEqual = false;
                return;
            end

            if ~strcmp(strjoin(cellstr(this.XLabel), newline), strjoin(cellstr(that.XLabel), newline))
                areEqual = false;
                return;
            end

            if ~strcmp(strjoin(cellstr(this.YLabel), newline), strjoin(cellstr(that.YLabel), newline))
                areEqual = false;
                return;
            end

            if ~strcmp(strjoin(cellstr(this.ZLabel), newline), strjoin(cellstr(that.ZLabel), newline))
                areEqual = false;
                return;
            end


            if ~isequal(this.Position,that.Position)
                areEqual = false;
                return;
            end

            if ~isequal(this.PlotBox,that.PlotBox)
                areEqual = false;
                return;
            end

            thisStruct = struct('XData', this.XData, 'YData', this.YData,...
                'ZData', this.ZData, 'Color', this.Color, 'Legend', this.Legend,...
                'Marker', this.Marker, 'LineStyle', this.LineStyle);

            thatStruct = struct('XData', that.XData, 'YData', that.YData,...
                'ZData', that.ZData, 'Color', that.Color, 'Legend', that.Legend,...
                'Marker', that.Marker, 'LineStyle', that.LineStyle);
            if length(thisStruct) ~= length(thatStruct)
                areEqual = false;
                return;
            end
            
            LinePropsCheck = false(1,length(thisStruct));
            for i = 1:length(thisStruct)
                for j = 1:length(thatStruct)
                    if isequaln(thisStruct(i),thatStruct(j))
                        LinePropsCheck(i) = true;
                        break;
                    end
                end
            end

            if ~all(LinePropsCheck)
                areEqual = false;
                return;
            else
                areEqual = true;
                return;
            end
        end
        function [html] = generateFeedback(this, that)
        %% generateFeedback: Generates HTML feedback for the student and solution Plot.
        %
        % generateFeedback will return the feedback for the student's plot.
        %
        % [HTML] = generateFeedback(PLOT) will return a character vector in
        % HTML that contains the markup for HTML. The contents of this
        % vector will be the feedback associated with a student's plot.
        %
        %%% Remarks
        %
        % This function will output a character after calling the
        % generateFeedback method with input as the student plot submission
        % and the solution plot.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:PLOT:GENERATEFEEDBACK:MISSINGPLOT exception will be
        % thrown if the student or solution plots are missing from the
        % generateFeedback method call.
        %
        %%% Unit Tests
        %
        % When called, the generateFeedback method will check the student
        % Plot against the solution Plot. If the student plot matches the
        % solution plot, the character HTML vector will contain both the
        % solution and student plot. It will also contain confirmation that
        % the plot was correct.
        %
        % If the student plot does not matches the solution plot, the
        % character HTML vector will contain both the solution and student
        % plot. It will also contain a description of why the student plot
        % is not correct, referencing the solution plot as needed.
        %
        % An AUTOGRADER:Plot:generateFeedback:noPlot exception will be
        % thrown if generateFeedback is called with only one or no input
        % Plots.
        %
        if ~isa(that,'Plot')
            ME = MException('AUTOGRADER:Plot:generateFeedback:noPlot',...
                'input is not a valid instance of Plot');
            throw(ME);
        end
        studPlot = img2base64(this.Image);
        solnPlot = img2base64(that.Image);
        html = sprintf(['<div class="row"><div class="col-md-6 text-center">', ...
            '<h2 class="text-center">Your Plot</h2><img class="img-fluid img-thumbnail" src="%s">', ...
            '</div><div class="col-md-6 text-center"><h2 class="text-center"> Solution Plot</h2>', ...
            '<img class="img-fluid img-thumbnail" src="%s"></div></div>'],...
            studPlot, solnPlot);

        end
    end
end

function data = roundData(data)
    sigs = arrayfun(@(i)(length(num2str(i))), abs(data)) - Student.ROUNDOFF_ERROR;
    data = arrayfun(@(d, s)(round(double(d), s)), data, sigs);
end