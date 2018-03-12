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

end