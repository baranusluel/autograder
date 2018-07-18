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
        Points;
        Segments;
        Limits;
    end
    properties (Constant)
        POSITION_MARGIN = 0.05;
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
            this.Position = round(pHandle.Position, ...
                Student.ROUNDOFF_ERROR);
            this.PlotBox = round(pHandle.PlotBoxAspectRatio, ...
                Student.ROUNDOFF_ERROR);
            this.Limits = round([pHandle.XLim, pHandle.YLim, pHandle.ZLim], ...
                Student.ROUNDOFF_ERROR);
            
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
                this.Points = [];
                this.Segments = [];
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
            xcell = cellfun(@(xx)(round(double(xx), Student.ROUNDOFF_ERROR)), xcell, 'uni', false);
            ycell = cellfun(@(yy)(round(double(yy), Student.ROUNDOFF_ERROR)), ycell, 'uni', false);
            zcell = cellfun(@(zz)(round(double(zz), Student.ROUNDOFF_ERROR)), zcell, 'uni', false);
            
            % Remove data points that have NaN in any axis
            for i = 1:length(lines) % for each cell / line
                xdata = xcell{i};
                ydata = ycell{i};
                zdata = zcell{i};
                points = max([length(xdata), length(ydata), length(zdata)]); % number of data points
                xNaN = false(1,points);
                yNaN = false(1,points);
                zNaN = false(1,points);
                if ~isempty(xdata)
                    xNaN = isnan(xdata);
                end
                if ~isempty(ydata)
                    yNaN = isnan(ydata);
                end
                if ~isempty(zdata)
                    zNaN = isnan(zdata);
                end
                pointNaN = xNaN | yNaN | zNaN;
                if ~isempty(xdata)
                    xcell{i} = xdata(~pointNaN);
                end
                if ~isempty(ydata)
                    ycell{i} = ydata(~pointNaN);
                end
                if ~isempty(zdata)
                    zcell{i} = zdata(~pointNaN);
                end
            end
            
            legend = {lines.DisplayName};
            color = {lines.Color};
            marker = {lines.Marker};
            marker(strcmp(marker, 'none')) = {''};
            linestyle = {lines.LineStyle};
            linestyle(strcmp(linestyle, 'none')) = {''};
            
            % Point Chaining
            % combine points that have the same line style of NO LINE, the
            % same marker style, and the same color
            i = 1;
            while i <= numel(linestyle)
                if isempty(linestyle{i})
                    j = i + 1;
                    while j <= numel(linestyle)
                        if isempty(linestyle{j}) && ...
                            strcmp(marker{i}, marker{j}) && ...
                            isequal(color{i}, color{j})
                            % engage
                            xcell{i} = [xcell{i} xcell{j}];
                            ycell{i} = [ycell{i} ycell{j}];
                            zcell{i} = [zcell{i} zcell{j}];
                            xcell(j) = [];
                            ycell(j) = [];
                            zcell(j) = [];
                            color(j) = [];
                            marker(j) = [];
                            linestyle(j) = [];
                            legend(j) = [];
                            j = j - 1;
                        end
                        j = j + 1;
                    end
                end
                i = i + 1;
            end
            
            % Roll Call
            %
            % Plots are really just a bunch of line segments. So, we can
            % break it up into each component line segment, where each
            % segment is just two coordinates
            
            % Structure is as follows:
            % segments is a cell array of segments. EACH segment carries a
            % 1x3 cell array; the first index is xvals, second is yvals,
            % third is zvals. These vals represent that particular segment,
            % and are ALWAYS sorted from low to high.
            
            % # segments/line = #points/line - 1
            % # segments = SUM(segments/line) for all lines
            totalSegs = 0;
            for i = 1:length(xcell)
                if ~isempty(linestyle{i})
                    totalSegs = totalSegs + numel(xcell{i}) - 1;
                end
            end
            segments = cell(1, totalSegs);
            segmentColors = cell(size(segments));
            segmentMarkers = cell(size(segments));
            segmentStyles = cell(size(segments));
            segmentLegends = cell(size(segments));
            counter = 1;
            for i = 1:length(xcell)
                if ~isempty(linestyle{i})
                    tmp = line2segments(xcell{i}, ycell{i}, zcell{i});
                    segments(counter:(counter+length(tmp)-1)) = tmp;
                    segmentColors(counter:(counter+length(tmp)-1)) = color(i);
                    segmentMarkers(counter:(counter+length(tmp)-1)) = marker(i);
                    segmentStyles(counter:(counter+length(tmp)-1)) = linestyle(i);
                    segmentLegends(counter:(counter+length(tmp)-1)) = legend(i);
                    counter = counter + length(tmp);
                end
            end
            % Find Uniqueness:
            % for each one, iterate over others; each one, if equal,
            % delete.
            c = 1;
            while c <= length(segments)
                % iterate over rest of segments
                seg = segments(c);
                for j = (c+1):length(segments)
                    if isequal(seg, segments(j))
                        segments(j) = [];
                        break;
                    end
                end
                c = c + 1;
            end
            % Sorting this would make comparison faster - but would the
            % sorting actually be slower than just comparing unsorted?
            
            % Sort order doesn't actually matter for equality; it can just
            % make it faster. So our sort algorithm doesn't actually have
            % to be fully unique, so just sorting by X values should be
            % good enough, while still being quite spritely
            
            this.Segments = struct('Segment', segments, ...
                'Color', segmentColors, ...
                'Marker', segmentMarkers, ...
                'LineStyle', segmentStyles, ...
                'Legend', segmentLegends);
            segXPts = arrayfun(@(s)(s.Segment{1}(1)), this.Segments);
            [~, inds] = sort(segXPts);
            this.Segments = this.Segments(inds);
            function segments = line2segments(xx, yy, zz)
                % a single line is guaranteed to be of the same color,
                % style, etc. - that's why it's a line!
                if ~isempty(zz)
                    segments = cell(1, numel(xx) - 1);
                    for idx = 1:length(xx)-1
                        first = [num2str(xx(idx)) ' ' num2str(yy(idx)) ' ' num2str(zz(idx))];
                        last = [num2str(xx(idx+1)) ' ' num2str(yy(idx+1)) ' ' num2str(zz(idx+1))];
                        [~, order] = sort({first last});
                        if order(1) == 1
                            segments{idx} = {[xx(idx) xx(idx+1)], ...
                                [yy(idx) yy(idx+1)], ...
                                [zz(idx) zz(idx+1)]};
                        else
                            segments{idx} = {[xx(idx+1) xx(idx)], ...
                                [yy(idx+1) yy(idx)], ...
                                [zz(idx+1) zz(idx)]};
                        end
                    end
                else
                    segments = cell(1, numel(xx) - 1);
                    for idx = 1:length(xx)-1
                        first = [num2str(xx(idx)) ' ' num2str(yy(idx))];
                        last = [num2str(xx(idx+1)) ' ' num2str(yy(idx+1))];
                        [~, order] = sort({first last});
                        if order(1) == 1
                            segments{idx} = {[xx(idx) xx(idx+1)], ...
                                [yy(idx) yy(idx+1)], ...
                                []};
                        else
                            segments{idx} = {[xx(idx+1) xx(idx)], ...
                                [yy(idx+1) yy(idx)], ...
                                []};
                        end
                    end
                end
            end
            % for every line that has no line style, we should sort it.
            % every point should be documented; EACH point is it's own
            % structure
            % for each line that has no line style, get it
            mask = strcmp(linestyle, '');
            % get X, Y, Z, Marker, Legend, Color
            ptXData = xcell(mask);
            ptYData = ycell(mask);
            if ~all(cellfun(@isempty, zcell))
                ptZData = zcell(mask);
            else
                ptZData = cell(1, sum(mask));
            end
            % z data?
            ptMarker = marker(mask);
            ptColor = color(mask);
            ptLegend = legend(mask);
            % get total amnt of points
            totalPoints = 0;
            for p = 1:numel(ptXData)
                totalPoints = totalPoints + numel(xcell{p});
            end
            ptData = cell(1, totalPoints);
            points = struct('X', ptData, ...
                'Y', ptData, ...
                'Z', ptData, ...
                'Marker', ptData, ...
                'LineStyle', '', ...
                'Legend', ptData, ...
                'Color', ptData);
            counter = 1;
            for i = 1:length(ptXData)
                % just separate X, Y, Z points
                xx = num2cell(ptXData{i});
                yy = num2cell(ptYData{i});
                zz = ptZData{i};
                mark = ptMarker{i};
                col = ptColor{i};
                leg = ptLegend{i};
                if isempty(zz)
                    zz = {[]};
                else
                    zz = num2cell(zz);
                end
                [points(counter:(counter+length(xx)-1)).X] = deal(xx{:});
                [points(counter:(counter+length(xx)-1)).Y] = deal(yy{:});
                [points(counter:(counter+length(xx)-1)).Z] = deal(zz{:});
                [points(counter:(counter+length(xx)-1)).Marker] = deal(mark);
                [points(counter:(counter+length(xx)-1)).Color] = deal(col);
                [points(counter:(counter+length(xx)-1)).Legend] = deal(leg);
                counter = counter + length(xx);
            end
            % Unique check
            % for all pts, if any point is identical, kill it
            while p <= length(points)
                pt = points(p);
                for j = (p+1):length(points)
                    if isequal(pt, points(j))
                        points(j) = [];
                    end
                end
                p = p + 1;
            end
            
            % Sort, just like we did with Segments:
            [~, inds] = sort([points.X]);
            points = points(inds);
                    
            
            this.Points = points;
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

            if any(this.Position < (that.Position - Plot.POSITION_MARGIN)) ...
                    || any(this.Position > (that.Position + Plot.POSITION_MARGIN))
                areEqual = false;
                return;
            end
            
            if any(this.PlotBox < (that.PlotBox - Plot.POSITION_MARGIN)) ...
                    || any(this.PlotBox > (that.PlotBox + Plot.POSITION_MARGIN))
                areEqual = false;
                return;
            end
            % for limits, if no ZData, then only compare first four
            if ~isequal(this.Limits(1:4), that.Limits(1:4))
                areEqual = false;
                return;
            end
            % Point Call
            % for each point set, see if found in this
            thatPoints = that.Points;
            thisPoints = this.Points;
            
            for i = numel(thatPoints):-1:1
                thatPoint = thatPoints(i);
                % look through thisSegs; once found, delete from both
                isFound = false;
                for j = numel(thisPoints):-1:1
                    if isequal(thatPoint, thisPoints(j))
                        isFound = true;
                        thisPoints(j) = [];
                        thatPoints(i) = [];
                        break;
                    end
                end
                if ~isFound
                    areEqual = false;
                    return;
                end
            end
            if ~isempty(thisPoints) || ~isempty(thatPoints)
                areEqual = false;
                return;
            end
            % Nothing should be left in either set; if both sets are
            % non-empty, then false
            thatPoints = that.Points;
            thisPoints = this.Points;
            for i = 1:numel(thatPoints)
                isFound = false;
                for j = 1:numel(thisPoints)
                    if isequal(thatPoints(i), thisPoints(j))
                        isFound = true;
                        break;
                    end
                end
                if ~isFound
                    areEqual = false;
                    return;
                end 
            end

            % Roll Call
            % for each line segment in that, see if found in this
            % Since they are unique, remove from both sets when found.
            % Then, at end, if both are empty, equal; otherwise, unequal.
            thatSegs = that.Segments;
            thisSegs = this.Segments;
            
            for i = numel(thatSegs):-1:1
                thatSeg = thatSegs(i);
                % look through thisSegs; once found, delete from both
                isFound = false;
                for j = numel(thisSegs):-1:1
                    if isequal(thatSeg, thisSegs(j))
                        isFound = true;
                        thisSegs(j) = [];
                        thatSegs(i) = [];
                        break;
                    end
                end
                if ~isFound
                    areEqual = false;
                    return;
                end
            end
            % Nothing should be left in either set; if both sets are
            % non-empty, then false
            if ~isempty(thisSegs) || ~isempty(thatSegs)
                areEqual = false;
            else
                areEqual = true;
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
            '</div><div class="col-md-6 text-center"><h2 class="text-center">Solution Plot</h2>', ...
            '<img class="img-fluid img-thumbnail" src="%s"></div></div>'],...
            studPlot, solnPlot);

        end
    end
end