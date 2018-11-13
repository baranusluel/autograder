%% Point: Contains the Data for a Point on a Plot
%
% stores the coordinate, marker, and color for a point on a plot
%
%%% Fields
%
% * X: 
%
% * Y:
%
% * Z:
%
% * Marker:
% 
% * Color:
%
%%% Methods
%
% * Point: makes the points. Give it a 1x2 vec or a 1x3 vec. Doesnt matter.
% Give it one input if there is no marker. give it 3 if there is bc color
% matter 
%
% * Equals: obviously returns if two points are the same
%
% * dataEquals: does equals but ignores color and marker. 
%
%%% Remarks
% 
% hey

classdef Point < handle
    properties (Access = public)
        X;
        Y;
        Z;
        Marker = '';
        Color;
    end
    methods (Access = public)
        function this = Point(coord,marker,color)
            %% Constructor
            %
            % creates an instance of Points from a vector containing
            % coordinate data, char vec of marker, and char vec of color
            %
            %%% Remarks
            % makes the points. Give it a 1x2 vec or a 1x3 vec. Doesnt
            % matter. Give it one input if there is no marker. give it 3 if
            % there is bc color matter
            if nargin == 0
                return;
            end
            this.X = coord(1);
            this.Y = coord(2);
            if length(coord) == 3
                this.Z = coord(3);
            else
                this.Z = 0;
            end
            if nargin > 1
                this.Marker = marker;
                this.Color = color;
            else
                this.Marker = '';
                this.Color = [0 0 0];
            end
        end
        function areEqual = equals(this,that)
            %% Equals: does the equals thing
            % you know this
            if isempty(this)
                areEqual = [];
                return;
            elseif isempty(that)
                areEqual = false;
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
            areEqual = this.dataEquals(that) ...
                & strcmp({this.Marker},{that.Marker}) ...
                & cellfun(@isequal, {this.Color}, {that.Color});
            if isscalar(orig)
                areEqual = reshape(areEqual, size(that));
            else
                areEqual = reshape(areEqual, size(orig));
            end
        end
        function tf = ne(this, that)
            tf = ~this.equals(that);
        end
        function tf = eq(this, that)
            tf = this.equals(that);
        end
        function areEqual = dataEquals(this,that)
            %% dataEquals: does the equals thing
            % you know this too
            areEqual = [this.X] == [that.X] ...
                & [this.Y] == [that.Y] ...
                & [this.Z] == [that.Z];
            areEqual = reshape(areEqual, size(this));
        end
        
        function [sorted, inds] = sort(points, varargin)
            if isempty(points)
                sorted = points;
                inds = [];
                return;
            elseif isscalar(points)
                sorted = points;
                inds = 1;
                return;
            end
            xx = reshape([points.X], [], 1);
            yy = reshape([points.Y], [], 1);
            zz = reshape([points.Z], [], 1);
            colors = vertcat(points.Color);
            markers = reshape(string({points.Marker}), [], 1);
            tmp = compose('%0.5f %0.5f %0.5f %d %d %d %s', ...
                [xx, yy, zz], ...
                colors, ...
                markers);
            [~, inds] = sort(tmp, varargin{:});
            sorted = points(inds);
        end
        
    
    end
    
    methods (Static)
    end
end