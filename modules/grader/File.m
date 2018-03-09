%% File: Represent a file
%
% This class helps in storing and comparing files.
%
%%% Fields
%
% * name: The filename for the file, without extension
%
% * extension: The file extension
%
% * data: One of the following:
%		- MxNx3 uint8 image
%		- String array of lines (without newline characters)
%		- Cell array for raw Excel output
% 
%%% Methods
%
% * equals
% * generateFeedback
%
%%% Remarks
%
%
classdef File < handle
    properties (Access = public)
        name;
        extension;
		data;
    end
    methods (Access = public)
        %% equals: Determine file equality
        %
        % Checks if this file object is equal to another (containing same name,
		% extension, and data).
        %
        % [ISEQUAL, MSG] = equals(THIS, OTHER) checks whether THIS is equal to 
		% OTHER. If THIS and OTHER have the same name, extension, and data, ISEQUAL
		% will be true. If the two file objects are not the same, ISEQUAL is false,
		% and MSG contains the reason why the files aren't equal.
        %
        %%% Remarks
        %
        %
        %%% Exceptions
        %
        % An AUTOGRADER:FILE:EQUALS:NOFILE exception will be thrown if OTHER
        % is not of type File, or no input is given.
		%
        %%% Unit Tests
        %
        %    Given that F is a valid File instance that is equal to THIS:
		%    [ISEQUAL, MSG] = equals(THIS, F)
		%
		%	 ISEQUAL -> true
		%	 MSG -> ''
        %    
        %    If B is a valid File instance with one or more fields not equal
		%    to the fields of THIS:
		%	 [ISEQUAL, MSG] = equals(THIS, B)
		%
		%	 ISEQUAL -> false
		%	 MSG contains a message describing how B differs from THIS.
        %
        %    If C is an invalid File instance or not type File:
		%	 [ISEQUAL, MSG] = equals(THIS, C)
		%
		%	 equals threw AUTOGRADER:FILE:EQUALS:NOFILE exception
		%
		% 	 [ISEQUAL, MSG] = equals()
		%
		%    equals threw AUTOGRADER:FILE:EQUALS:NOFILE exception
        %
        %    
        function [isEqual, message] = equals(this, other)
            
        end
		
		%% generateFeedback: Generate HTML feedback for students
        %
        % Create an HTML page for the student based on the solution File object.
        %
        % [HTML] = generateFeedback(THIS, SOLN) creates a feedback file containing
		% information the equality of THIS and SOLN, where THIS and SOLN are both
		% type File. If SOLN is a text file, HTML contains a visdiff() of the two
		% files. If SOLN is an image, the Image Comparison Tool will be used. If 
		% SOLN is an Excel file, both files will be converted to tables and visdiff()
		% will be used to compare.
        %
        %%% Remarks
        %
        %
        %%% Exceptions
        %
        % An AUTOGRADER:FILE:EQUALS:NOFILE exception will be thrown if SOLN
        % is not of type File, or no input is given.
		%
        %%% Unit Tests
        %
        %    Given that F is a valid File instance that is equal to THIS:
		%    [OUT] = generateFeedback(THIS, F)
		%
		%	 OUT will contain HTML describing that THIS and F are equal files.
        %    
        %    Given that B is a valid File instance that is not equal to THIS:
		%	 [OUT] = generateFeedback(this, B)
		%
		%	 OUT will contain HTML describing that THIS and B are not the same.
		%   
        %    If C is an invalid File instance or not type File:
		%	 [HTML] = generateFeedback(THIS, C)
		%
		%	 equals threw AUTOGRADER:FILE:EQUALS:NOFILE exception
		%
		%	 [HTML] = generateFeedback()
		%
		%    equals threw AUTOGRADER:FILE:EQUALS:NOFILE exception
        %
        %    
        function [html] = generateFeedback(this, other)
            
        end
    end
end