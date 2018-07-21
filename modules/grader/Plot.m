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
            if iscell(pHandle.Title.String)
                this.Title = strjoin(pHandle.Title.String, newline);
            else
                this.Title = pHandle.Title.String;
            end
            if iscell(pHandle.XLabel.String)
                this.XLabel = strjoin(pHandle.XLabel.String, newline);
            else
                this.XLabel = pHandle.XLabel.String;
            end
            if iscell(pHandle.YLabel.String)
                this.YLabel = strjoin(pHandle.YLabel.String, newline);
            else
                this.YLabel = pHandle.YLabel.String;
            end
            if iscell(pHandle.ZLabel.String)
                this.ZLabel = strjoin(pHandle.ZLabel.String, newline);
            else
                this.ZLabel = pHandle.ZLabel.String;
            end
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
            segmentStyles = cell(size(segments));
            segmentLegends = cell(size(segments));
            counter = 1;
            for i = 1:length(xcell)
                if ~isempty(linestyle{i})
                    tmp = line2segments(xcell{i}, ycell{i}, zcell{i});
                    segments(counter:(counter+length(tmp)-1)) = tmp;
                    segmentColors(counter:(counter+length(tmp)-1)) = color(i);
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
                for j = length(segments):-1:(c+1)
                    if isequal(seg, segments(j))
                        segments(j) = [];
                        segmentColors(j) = [];
                        segmentStyles(j) = [];
                        segmentLegends(j) = [];
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
            % Plots are connections between points and the points
            % themselves. Every POINT is its own thing as well
            % get X, Y, Z, Marker, Legend, Color

            % get total amnt of points
            totalPoints = 0;
            for p = 1:numel(xcell)
                if ~isempty(marker{p})
                    totalPoints = totalPoints + numel(xcell{p});
                end
            end
            ptData = cell(1, totalPoints);
            points = struct('X', ptData, ...
                'Y', ptData, ...
                'Z', ptData, ...
                'Marker', ptData, ...
                'Legend', ptData, ...
                'Color', ptData);
            counter = 1;
            for i = 1:length(xcell)
                if ~isempty(marker{i})
                    % just separate X, Y, Z points
                    xx = num2cell(xcell{i});
                    yy = num2cell(ycell{i});
                    zz = zcell{i};
                    mark = marker{i};

                    col = color{i};
                    leg = legend{i};
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
            end
            % Unique check
            % for all pts, if any point is identical, kill it
            while p <= length(points)
                pt = points(p);
                for j = length(points):-1:(p+1)
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
            if ~strcmp(this.Title, that.Title)
                areEqual = false;
                return;
            end

            if ~strcmp(this.XLabel, that.XLabel)
                areEqual = false;
                return;
            end

            if ~strcmp(this.YLabel, that.YLabel)
                areEqual = false;
                return;
            end

            if ~strcmp(this.ZLabel, that.ZLabel)
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

        % Find out why
        % title
        % x,y,zlabel
        % position
        % plotbox
        % segs
        % pts
        % limits
        msg = '';
        if ~strcmp(this.Title, that.Title)
            msg = sprintf('You gave title "%s", but we expected "%s"', ...
                this.Title, that.Title);
        elseif ~strcmp(this.XLabel, that.XLabel)
            msg = sprintf('You have an X Label of "%s", but we expected "%s"', ...
                this.XLabel, that.XLabel);
        elseif ~strcmp(this.YLabel, that.YLabel)
            msg = sprintf('You have a Y Label of "%s", but we expected "%s"', ...
                this.YLabel, that.YLabel);
        elseif ~strcmp(this.ZLabel, that.ZLabel)
            msg = sprintf('You have a Z Label of "%s", but we expected "%s"', ...
                this.ZLabel, that.ZLabel);
        elseif any(this.Position < (that.Position - Plot.POSITION_MARGIN)) ...
                    || any(this.Position > (that.Position + Plot.POSITION_MARGIN))
            msg = sprintf(['Your plot has a position of [%0.2f, %0.2f, %0.2f, %0.2f], ', ...
                'but we expected [%0.2f, %0.2f, %0.2f, %0.2f] (Did you call subplot correctly?)'], ...
                this.Position(1), this.Position(2), this.Position(3), this.Position(4), ...
                that.Position(1), that.Position(2), that.Position(3), that.Position(4));
        elseif any(this.PlotBox < (that.PlotBox - Plot.POSITION_MARGIN)) ...
                    || any(this.PlotBox > (that.PlotBox + Plot.POSITION_MARGIN))
            msg = sprintf(['Your plot has a Plot Box of [%0.2f, %0.2f, %0.2f], ', ...
                'but we expected [%0.2f, %0.2f, %0.2f] (Did you call subplot correctly?)'], ...
                this.PlotBox(1), this.PlotBox(2), this.PlotBox(3), ...
                that.PlotBox(1), that.PlotBox(2), that.PlotBox(3));
        else
            % we need to check Segs and Points
            % do roll call
            solnSegs = that.Segments;
            studSegs = this.Segments;
            isFound = false;
            for i = numel(solnSegs):-1:1
                solnSeg = solnSegs(i);
                isFound = false;
                for j = numel(studSegs):-1:1
                    if isequal(solnSeg, studSegs(j))
                        solnSegs(i) = [];
                        studSegs(j) = [];
                        isFound = true;
                        break;
                    end
                end
                if ~isFound
                    msg = sprintf('You didn''t plot segment (%0.2f, %0.2f)<i class="fas fa-arrow-right"></i>(%0.2f, %0.2f)', ...
                        solnSeg.Segment{1}(1), ...
                        solnSeg.Segment{2}(1), ...
                        solnSeg.Segment{1}(2), ...
                        solnSeg.Segment{2}(2));
                    break;
                end
            end
            if isFound && ~isempty(studSegs)
                seg = studSegs(1);
                msg = sprintf('You plotted segment (%0.2f, %0.2f)<i class="fas fa-arrow-right"></i>(%0.2f, %0.2f) when you shouldn''t have', ...
                    seg.Segment{1}(1), ...
                    seg.Segment{2}(1), ...
                    seg.Segment{1}(2), ...
                    seg.Segment{2}(2));
            end
            if isempty(msg)
                % look at points
                solnPoints = that.Points;
                studPoints = this.Points;
                isFound = false;
                for i = numel(solnPoints):-1:1
                    solnPoint = solnPoints(i);
                    isFound = false;
                    for j = numel(studPoints):-1:1
                        if isequal(solnPoint, studPoints(j))
                            solnPoints(i) = [];
                            studPoints(j) = [];
                            isFound = true;
                            break;
                        end
                    end
                    if ~isFound
                        msg = sprintf('You didn''t plot point (%0.2f, %0.2f)', ...
                            solnPoint.X, solnPoint.Y);
                        break;
                    end
                end
                if isFound && ~isempty(studPoints)
                    pt = studPoints(1);
                    msg = sprintf('You plotted point (%0.2f, %0.2f) when you shouldn''t have', ...
                        pt.X, pt.Y);
                end
            end
        end
        
        if isempty(msg) && ~isequal(this.Limits(1:4), that.Limits(1:4))
            msg = sprintf(['Your plot has Limits of [%0.2f, %0.2f, %0.2f, %0.2f], ', ...
                'but we expected [%0.2f, %0.2f, %0.2f, %0.2f] (Did you call axis or xlim/ylim correctly?)'], ...
                this.Limits(1), this.Limits(2), this.Limits(3), this.Limits(4), ...
                that.Limits(1), that.Limits(2), that.Limits(3), that.Limits(4));
        end
        
        studPlot = img2base64(this.Image);
        solnPlot = img2base64(that.Image);
        html = sprintf(['<div class="row"><div class="col-md-6 text-center">', ...
            '<h2 class="text-center">Your Plot</h2><img class="img-fluid img-thumbnail" src="%s">', ...
            '</div><div class="col-md-6 text-center"><h2 class="text-center">Solution Plot</h2>', ...
            '<img class="img-fluid img-thumbnail" src="%s"></div><div class="text-center col-12 exception"><p>%s</p></div></div>'],...
            studPlot, solnPlot, msg);

        end
    end
end