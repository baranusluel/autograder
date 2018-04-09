%% UnitResults: Run and record all tests for this Unit
%
% UnitResults is responsible for running all unit tests for the specified unit
%
%%% Fields
%
% * path: The path to this unit's directory
% * name: The name of this unit
% * passed: Whether or not all the unit tests passed
%
%%% Remarks
%
% This class runs all tests for the Unit
%

classdef UnitResults < handle
    properties (Access=public)
        path;
        name;
        passed;
    end
    methods
        function this = UnitResults(path)

        end
    end
    methods (Access=public)
        function html = generateHtml(this)

        end
    end
end