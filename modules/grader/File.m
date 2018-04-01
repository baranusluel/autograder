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
%
% * generateFeedback
%
%%% Remarks
%
% The File class represents all files possibly generated by a student's 
% (or solution's) code. A File Object can be created by the constructor, 
% which receives a path to the file to create. 
%
% **Once the File object is created, the original file can safely be 
% deleted from disk.** The File class holds all the information needed 
% to compare two files internally, so there is actually no link to the 
% original file.
%
classdef File < handle
    properties (Access = public)
        name;
        extension;
		data;
    end
    methods
        function this = File(path)
        %Given the path, will find all the files in the path
        fnst = dir(path)
        %For each file, extract the filename and extension to File class,
        %and extract the data contained in file
        for i = length(fnst)
           %grab the filename, parse by period, and store info in File
           name = fnst(i).name
           [nname filetype] = strtok(name, '.')
           File.name = [File.name {nname}]
           File.extension = [File.extension {filetype}]
           %depending on the filetype, extract the information
           switch filetype
               case '.txt' %read data in and create a vertical string vector
                   fh = fopen(name)
                   line = string(fgetl(fh))
                   data = string('')
                   while ischar(line)
                       data = [data; line]
                       line = string(fgetl(fh))
                   end
                   fclose(fh)
                   File.data = [File.data {data}]
               case {'.png', '.jpeg', '.jpg'} 
                   %read in image array and store in File class
                   data = imread(name)
                   File.data = [File.data {data}]
               case {'.xls', '.xlsx', '.xlsm'}
                   %should I be able to read in .csv?
                   [~,~,data] = xlsread(name)
                   File.data = [File.data {data}]
           end
        end
        %Then I need to use equals() to compare the files? I don't think I'm
        %grading, I should just compare the data I get from the student to
        %the solution code? Where does the solution code come from?
        
        %Once I get back the solution and the messages needed (perhaps just
        %say that it was correct if there was no error message to give), I
        %need to use generateFeedback to create an html that will neatly
        %display the feedback to the student. Time to learn html baby.
        end
    end
    methods (Access = public)
        %% equals: Determine file equality
        %
        % Checks if this file object is equal to another (containing same name,
		% extension, and data).
        %
        % [ISEQUAL, MSG] = equals(OTHER) checks whether THIS is equal to 
		% OTHER. If THIS and OTHER have the same name, extension, and data, ISEQUAL
		% will be true. If the two file objects are not the same, ISEQUAL is false,
		% and MSG contains the reason why the files aren't equal.
        %
        %%% Remarks
        %
        % Assuming the input file is indeed a File object, this method is 
        % guaranteed to never error. 
        % 
        %%% Exceptions
        %
        % An AUTOGRADER:FILE:EQUALS:NOFILE exception will be thrown if OTHER
        % is not of type File, or no input is given.
		%
        %%% Unit Tests
        %
        %    Given that F is a valid File instance that is equal to THIS:
		%    [ISEQUAL, MSG] = equals(F)
		%
		%	 ISEQUAL -> true
		%	 MSG -> ''
        %    
        %    If B is a valid File instance with one or more fields not equal
		%    to the fields of THIS:
		%	 [ISEQUAL, MSG] = equals(B)
		%
		%	 ISEQUAL -> false
		%	 MSG contains a message describing how B differs from THIS.
        %
        %    If C is an invalid File instance or not type File:
		%	 [ISEQUAL, MSG] = equals(C)
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
        % [HTML] = generateFeedback(SOLN) creates a feedback file containing
		% information the equality of THIS and SOLN, where THIS and SOLN are both
		% type File. If SOLN is a text file, HTML contains a visdiff() of the two
		% files. If SOLN is an image, the Image Comparison Tool will be used. If 
		% SOLN is an Excel file, both files will be converted to tables and visdiff()
		% will be used to compare.
        %
        %%% Remarks
        %
        % The HTML generated by this method is used within the Student class to 
        % generate the broader Student Feedback file.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:FILE:EQUALS:NOFILE exception will be thrown if SOLN
        % is not of type File.
        %
        % An AUTOGRADER:FILE:EQUALS:INVALIDFILE exception will be thrown if no 
        % input is given.
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
        %    If C is an invalid File instance:
		%	 [HTML] = generateFeedback(THIS, C)
		%
		%	 equals threw AUTOGRADER:FILE:EQUALS:INVALIDFILE exception
		%
        %    If C does not contain a vaild File path:
		%	 [HTML] = generateFeedback(THIS, C)
		%
		%	 equals threw AUTOGRADER:FILE:EQUALS:NOFILE exception
		%	 [HTML] = generateFeedback()
        %
        %    
        function [html] = generateFeedback(this, other)
            
        end
    end
end