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
            end
        end
        function areEqual = equals(this,that)
            %% Equals: does the equals thing
            % you know this
            areEqual = this.dataEquals(that) ...
                && strcmp(this.Marker,that.Marker) ...
                && isequal(this.Color,that.Color);
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
            areEqual = this.X == that.X && this.Y == that.Y ...
                && this.Z == that.Z;
        end
    
    end
end


