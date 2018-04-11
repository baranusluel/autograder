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
%		- Cell array of lines (without newline characters)
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
        name; %will be class str
        extension; %will be class str
        data; %will vary in file type
    end
    properties (Constant)
        SENTINEL = [tempfile '.lock'];
    end
    methods
        function this = File(path)
            %% Constructor: Create a File object from a path
            %
            % Represents a generated file and it's contents
            %
            % this = File(P) where P is a path for a specific file, will
            % generate a new File object with that file's data, name, and
            % extension.
            %
            %%% Remarks
            %
            % This function uses imformats. If you've changed it, it might not
            % work.
            %
            %%% Exceptions
            %
            % An AUTOGRADER:File:ctor:invalidPath exception will be thrown if
            % the given path isn't a valid file.
            %
            % An AUTOGRADER:File:ctor:invalidExtension exception will be thrown
            % if the extension isn't readable.
            %
            %%% Unit Tests
            %
            %   P = 'C:\Users\...\test.txt'; % valid path
            %   this = File(P);
            %
            %   File.name -> 'test'
            %   File.extension -> '.txt'
            %   File.data -> data (a string array with no newline characters)
            %
            %   P = ''; % invalid path
            %   this = File(P);
            %
            %   threw invalidPath exception
            %
            %   P = 'C:\test.fdasfdsa'; % invalid file extension
            %   this = File(P);
            %
            %   threw invalidExtension exception
            %
            %   P = 'C:\test\e.xls'; % valid file
            %   this = File(P);
            %
            %   this.name -> 'e';
            %   this.extension -> '.xls'
            %   this.data -> cell array of raw output
            %
            %   P = 'C:\test\img.png'; % valid file
            %   this = File(P);
            %
            %   this.name -> 'img'
            %   this.extension -> '.png'
            %   this.data -> UINT MxNx3 array
            %
            
            
            %Parse the path input into the proper parts
            [~, name, ext] = fileparts(path);
            
            %store info in File
            
            File.name = nname;
            File.extension = ext;
            %depending on the ext, extract the information
            %for images, imformats will be used for the potential cases
            %because we are using imformats, we will remove the periods
            %from the variable stored in ext when you use the
            %switch statements
            imc = imformats;
            imc = [imc.ext];
            switch ext(2:end)
                case 'txt' %read data in and create a vertical string vector
                    %In standard practice, using the string class to extract the
                    %contents of a text file would be preferable. Most TAs,
                    %however, would be more comfortable with cell arrays, so
                    %this is the method chosen.
                    %fh = fopen(name);
                    %line = fgetl(fh);
                    %data = {};
                    %while ischar(line)
                    %    data = [data; {line}];
                    %    line = fgetl(fh);
                    %end
                    %fclose(fh);
                    %File.data = data;
                    
                    %The above method is too slow since it iteratively
                    %concatenates; the superior method would be to use
                    %preallocating. However, Matlab makes even
                    %preallocating look lame af in the presence of the
                    %glorious fread function.
                    fid = fopen(name, 'rt');
                    lines = fread(fid)';
                    fclose(fid);
                    lines = char(lines);
                    lines = strsplit(lines, newline, 'CollapseDelimiters',...
                        false);
                    File.data = lines;
                case imc
                    %read in image array and store in File class
                    data = imread(name);
                    File.data = data;
                case {'xls', 'xlsx', 'csv'}
                    [~,~,data] = xlsread(name);
                    File.data = data;
            end
        end
    end
    methods (Access = public)
        function [isEqual, msg] = equals(this, soln)
            %% equals: Determine file equality
            %
            % Checks if this file object is equal to anSOLN (containing same name,
            % extension, and data).
            %
            % [ISEQUAL, MSG] = equals(THIS,SOLN) checks whether THIS is equal to
            % SOLN. If THIS and SOLN have the same name, extension, and data, ISEQUAL
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
            % An AUTOGRADER:File:equals:noFile exception will be thrown if SOLN
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
            %	 equals threw AUTOGRADER:File:equals:noFile exception
            %
            % 	 [ISEQUAL, MSG] = equals()
            %
            %    equals threw AUTOGRADER:File:equals:noFile exception
            %
            %
            
            %extract the data from classes, compare name and extension
            name = strcmp(this.name,soln.name)
            ext = strcmp(this.extension,soln.extension)
            data = isequal(this.data,soln.data)
            %depending on what is true, output proper message
            msg = ''
            isEqual = false
            %How descriptive should I be?
            if name & ext & data
                isEqual = true
            elseif name & ext & ~data
                msg = 'The data was found to be incorrect'
            elseif name & ~ext & data
                msg = 'The extension was found to be incorrect'
            elseif ~name & ext & data
                msg = 'The name was found to be incorrect'
            elseif name & ~ext & ~data
                msg = 'The extension and data was found to be incorrect'
            elseif ~name & ext & ~data
                msg = 'The name and data was found to be incorrect'
            elseif ~name & ~ext & data
                msg = 'The name and extension was found to be incorrect'
            else
                msg = 'the name, extension, and data were all found to be incorrect'
            end
                
        end
        function [html] = generateFeedback(this, soln)
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
            % An AUTOGRADER:File:equals:noFile exception will be thrown if SOLN
            % is not of type File.
            %
            % An AUTOGRADER:File:equals:invalidFile exception will be thrown if no
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
            %	 equals threw AUTOGRADER:File:equals:invalidFile exception
            %
            %    If C does not contain a vaild File path:
            %	 [HTML] = generateFeedback(THIS, C)
            %
            %	 equals threw AUTOGRADER:File:equals:noFile exception
            %	 [HTML] = generateFeedback()
            %
            %
        end
    end
end
%Code Written by: Tobin K Abraham