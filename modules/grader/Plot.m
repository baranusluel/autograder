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
        isAlien logical = false;
    end
    properties (Constant)
        POSITION_MARGIN = 0.05;
        ROUNDOFF_ERROR = 5;
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
        % Plot.
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
                Plot.ROUNDOFF_ERROR);
            this.PlotBox = round(pHandle.PlotBoxAspectRatio, ...
                Plot.ROUNDOFF_ERROR);
            this.Limits = round([pHandle.XLim, pHandle.YLim, pHandle.ZLim], ...
                Plot.ROUNDOFF_ERROR);
            
            tmp = figure('Visible', 'off');
            par = pHandle.Parent;
            pHandle.Parent = tmp;
            imgstruct = getframe(tmp);
            this.Image = imgstruct.cdata;
            
            pHandle.Parent = par;
            close(tmp);
            delete(tmp);

            lines = allchild(pHandle);
            if isempty(lines)
                tmp = Point();
                this.Points = tmp(false);
                tmp = Segment();
                this.Segments = tmp(false);
                return;
            end
            for i = length(lines):-1:1
                if ~isa(lines(i), 'matlab.graphics.chart.primitive.Line')
                    lines(i) = [];
                    this.isAlien = true;
                end
            end
            if isempty(lines)
                tmp = Point();
                this.Points = tmp(false);
                tmp = Segment();
                this.Segments = tmp(false);
                return;
            end
            xcell = {lines.XData};
            ycell = {lines.YData};
            zcell = {lines.ZData};
            
            % Round data to sigfig
            xcell = cellfun(@(xx)(round(double(xx), Plot.ROUNDOFF_ERROR)), xcell, 'uni', false);
            ycell = cellfun(@(yy)(round(double(yy), Plot.ROUNDOFF_ERROR)), ycell, 'uni', false);
            zcell = cellfun(@(zz)(round(double(zz), Plot.ROUNDOFF_ERROR)), zcell, 'uni', false);
            
            % Remove data points that have NaN in any axis
            for i = 1:length(lines) % for each cell / line
                xdata = xcell{i};
                ydata = ycell{i};
                zdata = zcell{i};
                pts = max([length(xdata), length(ydata), length(zdata)]); % number of data points
                xNaN = false(1,pts);
                yNaN = false(1,pts);
                zNaN = false(1,pts);
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
            counter = 1;
            for i = 1:length(xcell)
                if ~isempty(linestyle{i})
                    tmp = line2segments(xcell{i}, ycell{i}, zcell{i});
                    segments(counter:(counter+length(tmp)-1)) = tmp;
                    segmentColors(counter:(counter+length(tmp)-1)) = color(i);
                    segmentStyles(counter:(counter+length(tmp)-1)) = linestyle(i);
                    counter = counter + length(tmp);
                end
            end
            % get rid of empty extra
            segments((counter):end) = [];
            segmentColors((counter):end) = [];
            segmentStyles((counter):end) = [];
            % 
            % Sorting this would make comparison faster - but would the
            % sorting actually be slower than just comparing unsorted?
            
            % Sort order doesn't actually matter for equality; it can just
            % make it faster. So our sort algorithm doesn't actually have
            % to be fully unique, so just sorting by X values should be
            % good enough, while still being quite spritely
            for s = numel(segments):-1:1
                segs(s) = Segment(segments{s}{:}, ...
                    segmentColors{s}, ...
                    segmentStyles{s});
            end
            if isempty(segments)
                segs = Segment();
                segs = segs(false);
            end 
            segs = unique(segs);
            this.Segments = segs;
            segXPts = arrayfun(@(s)(s.Start(1)), this.Segments);
            [~, inds] = sort(segXPts);
            this.Segments = this.Segments(inds);
            function segments = line2segments(xx, yy, zz)
                % a single line is guaranteed to be of the same color,
                % style, etc. - that's why it's a line!
                if ~isempty(zz)
                    segments = cell(1, numel(xx) - 1);
                    mask = false(1, numel(xx) - 1);
                    for idx = 1:length(xx)-1
                        if xx(idx) ~= xx(idx+1) || ...
                                yy(idx) ~= yy(idx+1) || ...
                                zz(idx) ~= zz(idx+1)
                            mask(idx) = true;
                            first = [num2str(xx(idx)) ' ' num2str(yy(idx)) ' ' num2str(zz(idx))];
                            last = [num2str(xx(idx+1)) ' ' num2str(yy(idx+1)) ' ' num2str(zz(idx+1))];
                            [~, order] = sort({first last});
                            if order(1) == 1
                                segments{idx} = {[xx(idx) yy(idx) zz(idx)], ...
                                    [xx(idx+1) yy(idx+1) zz(idx+1)]};
                            else
                                segments{idx} = {[xx(idx+1) yy(idx+1) zz(idx+1)], ...
                                    [xx(idx) yy(idx) zz(idx)]};
                            end
                        end
                    end
                    segments = segments(mask);
                else
                    segments = cell(1, numel(xx) - 1);
                    mask = false(1, numel(xx) - 1);
                    for idx = 1:length(xx)-1
                        if xx(idx) ~= xx(idx+1) || yy(idx) ~= yy(idx+1)
                            mask(idx) = true;
                            first = [num2str(xx(idx)) ' ' num2str(yy(idx))];
                            last = [num2str(xx(idx+1)) ' ' num2str(yy(idx+1))];
                            [~, order] = sort({first last});
                            if order(1) == 1
                                segments{idx} = {[xx(idx) yy(idx)], ...
                                    [xx(idx+1) yy(idx+1)]};
                            else
                                segments{idx} = {[xx(idx+1) yy(idx+1)], ...
                                    [xx(idx) yy(idx)]};
                            end
                        end
                    end
                    segments = segments(mask);
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
            
            n = totalPoints;
            for i = 1:length(xcell)
                if ~isempty(marker{i})
                    % just separate X, Y, Z points
                    xx = xcell{i};
                    yy = ycell{i};
                    zz = zcell{i};
                    if isempty(zz)
                        zz = zeros(1,length(xx));
                    end
                    mark = marker{i};
                    col = color{i};
                    for j = length(xx):-1:1
                        points(n) = Point([xx(j) yy(j) zz(j)], ...
                            mark, col);
                        n = n - 1;
                    end
                end
            end
            if totalPoints == 0
                points = Point();
                points = points(false);
            end
            % Unique check
            % for all pts, if any point is identical, kill it
            points = unique(points);
            this.Points = points;
            this.Segments = unique(this.Segments);
            this.Points = unique(this.Points);
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
            % use ismember! If all of student points are member, AND all of
            % soln points are member, then yes
            if ~all(ismember(thisPoints, thatPoints)) ...
                    || ~all(ismember(thatPoints, thisPoints))
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
            
            if ~all(ismember(thisSegs, thatSegs)) ...
                    || ~all(ismember(thatSegs, thisSegs))
                areEqual = false;
                return;
            end
            areEqual = true;
        end
        %% pointEquals: Check Plotted Equality
        %
        % pointEquals is like dataEquals, except it only checks exact
        % points plotted - i.e., is the raw plotted data the same
        function areEqual = pointEquals(this, that)
            extractor = @(seg)([seg.Start, seg.Stop]);
            thisPoints = [this.Points, extractor(this.Segments)];
            thatPoints = [that.Points, extractor(that.Segments)];
            areEqual = all(ismember(thisPoints, thatPoints));
        end
        %% dataEquals: Check Data Equality
        %
        % dataEquals is the same as equals, except it strictly checks point
        % and segment data - raw coordinates.
        function areEqual = dataEquals(this, that)
            % already unique & sorted; just do dataEquals of points and
            % segs
            if numel(this.Points) ~= numel(that.Points) ...
                    || numel(this.Segments) ~= numel(that.Segments)
                areEqual = false;
            elseif ~all(dataEquals(this.Points, that.Points)) ...
                    || ~all(dataEquals(this.Segments, that.Segments))
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
        if this.isAlien
            msg = 'You plotted something other than lines or points, so we could not grade your submission';
        elseif ~strcmp(this.Title, that.Title)
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
            msg = 'Your plot has the wrong position (Did you call subplot correctly?)';
        elseif any(this.PlotBox < (that.PlotBox - Plot.POSITION_MARGIN)) ...
                    || any(this.PlotBox > (that.PlotBox + Plot.POSITION_MARGIN))
            msg = 'Your axes aren''t lined up (did you call axis correctly?';
        elseif ~isequal(this.Limits(1:4), that.Limits(1:4))
            msg = sprintf(['Your plot has Limits of [%0.2f, %0.2f, %0.2f, %0.2f], ', ...
                'but we expected [%0.2f, %0.2f, %0.2f, %0.2f] (Did you call axis or xlim/ylim correctly?)'], ...
                this.Limits(1), this.Limits(2), this.Limits(3), this.Limits(4), ...
                that.Limits(1), that.Limits(2), that.Limits(3), that.Limits(4));
        elseif this.dataEquals(that)
            % if data equals, we've alreay checked everything else. it has
            % to be styles (points or lines)
            msg = 'Your point or line styles are incorrect';
        else
            % if not even data equals, some bad data there
            msg = 'Your plot data differs from the solution';
        end
        msg = sprintf('%s. For more information, please use <code>checkPlots</code>', msg);
        
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