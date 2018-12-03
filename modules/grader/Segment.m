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
            pts = sort([this.Start, this.Stop]);
            this.Start = pts(1);
            this.Stop = pts(2);
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
            if isempty(this)
                tf = [];
                return;
            elseif isempty(that)
                tf = false;
                return;
            end
            orig = this;
            this = reshape(this, 1, []);
            that = reshape(that, 1, []);
            if isscalar(that)
                tmp(numel(this)) = that;
                tmp(:) = that;
                that = tmp;
                tmp = tmp(false);
            end
            if isscalar(this)
                tmp(numel(that)) = this;
                tmp(:) = this;
                this = tmp;
                
            end
            tf = this.dataEquals(that) ...
                & cellfun(@isequal, {this.Color}, {that.Color}) ...
                & strcmp({this.Style}, {that.Style});
            if isscalar(orig)
                tf = reshape(tf, size(that));
            else
                tf = reshape(tf, size(orig));
            end
        end
        
        function tf = eq(this, that)
            tf = this.equals(that);
        end
        
        function tf = ne(this, that)
            tf = ~this.equals(that);
        end
        
        function tf = dataEquals(this, that)
            if isempty(this) || isempty(that)
                tf = [];
            else
                tf = dataEquals([this.Start], [that.Start]) ...
                    & dataEquals([this.Stop], [that.Stop]);
                tf = reshape(tf, size(this));
            end
        end
        
        function [sorted, inds] = sort(segments, varargin)
            if isempty(segments)
                sorted = segments;
                inds = [];
                return;
            elseif isscalar(segments)
                sorted = segments;
                inds = 1;
                return;
            end
            % sort by Point start -> stop
            starts = [segments.Start];
            xx1 = reshape([starts.X], [], 1);
            yy1 = reshape([starts.Y], [], 1);
            zz1 = reshape([starts.Z], [], 1);
            stops = [segments.Stop];
            xx2 = reshape([stops.X], [], 1);
            yy2 = reshape([stops.Y], [], 1);
            zz2 = reshape([stops.Z], [], 1);
            styles = reshape(string({segments.Style}), [], 1);
            tmp = compose('%0.5f %0.5f %0.5f %0.5f %0.5f %0.5f %s', ...
                [xx1, yy1, zz1, xx2, yy2, zz2], styles);
            [~, inds] = sort(tmp, varargin{:});
            sorted = segments(inds);
            sorted = reshape(sorted, size(segments));
        end
    end
end