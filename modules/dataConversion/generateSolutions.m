%% generateSolutions: Generate the solution values for comparison 
%   
% This will generate the solution values, given a path to the 
% solution ZIP archive. These solutions are held in a `Problem` array.
%
% PROBLEMS = generateSolutions(PATH) will return a Problem Array containing
% the problems for the current homework specified by PATH, which is a
% string representation of the path to the solution ZIP archive
% 
%%% Remarks
% 
% Any exceptions thrown by the Problem class or sub classes will not be 
% caught by generateSolutions, and will instead by propogated forward.
% These errors are considered mostly fatal.
% 
% The JSON format is strictly enforced. For more information on what 
% this format should look like, see the central documentation. For 
% convenience, an example is shown below.
%
%   {
%     "Problems": [
%       {
%         "name": "ExampleProblem1",
%         "banned": [
%           "fopen",
%           "fclose",
%           "fseek",
%           "frewind"
%         ],
%         "TestCases": [
%           {
%             "call": "[out1, out2] = myFun(in1, in2);",
%             "initializer": "",
%             "points": 3,
%             "inputs": {
%               "in1": 5,
%               "in2": true
%             },
%             "supportingFiles": [
%               "myFile.txt",
%               "myInputImage.png"
%             ]
%           },
%           {
%             "call": "[out1, out2] = myFun(in1, in2);",
%             "initializer": "in2 = supportFunction__;",
%             "points": 3,
%             "inputs": {
%               "in1": 5
%             },
%             "supportingFiles": [
%               "myFile.txt",
%               "myInputImage.png",
%               "supportFunction__.m"
%             ]
%           }
%         ]
%       },
%       {
%         "name": "ExampleProblem2",
%         "banned": [
%           "size",
%           "parpool"
%         ],
%         "TestCases": [
%           {
%             "call": "[out1, out2] = myFun(in1, in2);",
%             "initializer": "",
%             "points": 3,
%             "inputs": {
%               "in1": 5,
%               "in2": true
%             },
%             "supportingFiles": [
%               "myFile.txt",
%               "myInputImage.png"
%             ]
%           },
%           {
%             "call": "[out1, out2] = myFun(in1, in2);",
%             "initializer": "in2 = supportFunction__;",
%             "points": 3,
%             "inputs": {
%               "in1": 5
%             },
%             "supportingFiles": [
%               "myFile.txt",
%               "myInputImage.png",
%               "supportFunction__.m"
%             ]
%           }
%         ]
%       }
%    ]
%  }
%
%%% Exceptions
% 
% generateSolutions throws exception 
% AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH if the input path is invalid
% or if necessary file is missing in the given directory
% 
%%% Unit Tests
% 
%   PATH = 'C:\Users\...\Soln.zip'; % Valid Solutions Archive
%   PROBLEMS = generateSolutions(PATH);
%
%   PROBLEMS -> Valid Problem Array
%
%   PATH = ''; % Inavlid Path
%   PROBLEMS = generateSolutions(PATH);
%
%   Threw INVALIDPATH exception
%
%   PATH = 'C:\Users\...\Soln.zip'; % Valid path, invalid solutions!
%   PROBLEMS = generateSolutions(PATH);
%
%   TestCase Threw exception <SolnException>
%
%   PATH = 'C:\Users\...\Soln.zip'; % Valid path, but incomplete archive
%   PROBLEMS = generateSolutions(PATH);
%
%   Threw INVALIDPATH exception
%
function problems = generateSolutions(path)
%first check if the path contains .zip at all. 
if contains(path,'.zip')
    %try-catch block to check catch if the path is invalid at all. 
    try
        
        %Find the path without the archive name.
        [filepath, name, ext] = fileparts(path)
        %Unzip the archive to the current folder.
        unzipArchive(path);
        %Decode the JSON
        fh = fopen('rubric.json');
        if fh==(-1)
            %Invalid archive.
            error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH')
        else
            raw = fread(fh,inf);
            str = char(raw'); 
            fclose(fid); 
            val = jsondecode(str);
        end
        
    catch ME
        if strcmp(ME.identifier,'MATLAB:checkfilename:invalidFilename')
            error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','Threw INVALIDPATH exception.')
        %Error message for valid path, but invalid archive.
        elseif strcmp(ME.identifier,'AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH')
            error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH', 'Threw INVALIDPATH exception.')
        elseif strcmp(ME.identifier,'MATLAB:json:ExpectedLiteral')
            error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH', 'Threw INVALIDPATH exception. JSON formatting is not correct.')
        else
            error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH', 'Threw INVALIDPATH exception.')
        end
    end
    
        rubric = jsondecode()
        
    
else
    %Invalid Path
    error('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH')
end
end