%% TestCase: A single test for a homework submission
%
% This class defines a complete test case for a specific problem
%
%%% Fields
%
% * call: The complete function call 
% (i.e., |[out1, out2] = myFunction(in1, in2);|)
% * initializer: The complete function call for a function to be run 
% immediately before testing the student's code.
% * points: The points possible for this specific test case
% * inputs: A structure where the field name is the name of the variable, 
% and the field value is the value of the variable
% * supportingFiles: A string array of complete file paths that will need 
% to be copied to the student's directory
% * outputs: A structure where the field name is the name of the output, 
% and the field value is the value of the output
% * images: A |File| array that represents the images produced as outputs
% * files: A |File| array that represents all the files produced as outputs
% * plots: A |Plot| array that represents the plots generated
%
%%% Methods
%
% * TestCase(string json);
%
%%% Remarks
%
% The |TestCase| class defines all the necessary settings and conditions to
% run a single test of a student's function. The |TestCase| class stores
% the instructions for running the test case, and includes the solution's
% outputs for comparison.
%
% The initializer is useful if a variable's value cannot be determined 
% until right before the function call. Each output's name must exactly 
% match the name of an input. The values for the outputs overwrite the 
% value for its corresponding input.
%
% For example, suppose |inputs| looked like this:
%
%   struct('fid', 0, 'outputName', 'helloWorld.txt');
%
% And suppose you wanted to populate |fid| with a valid file handle. 
% In that case, your |initializer| would look like:
%
%   [fid] = fopen('myInput.txt');
%
% Now suppose |fid| is now 3. This will overwrite the previous value of 
% |fid| (0) found in |inputs|. If you want a custom function to run 
% instead, include it as a supporting file and call it.
%
classdef TestCase
    properties (Access = public)
        call;
        initializer;
        points;
        inputs;
        supportingFiles;
        outputs;
        images;
        files;
        plots;
    end
    methods
        function this = TestCase(json)
            
        end
    end
end