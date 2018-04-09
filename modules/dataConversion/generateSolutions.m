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

%try-catch block to check if the path is invalid at all.
try
    %Unzip the archive to the current folder.
    unzipArchive(path);
    %Decode the JSON
    fh = fopen('rubric.json');
    raw = fread(fh,inf);
    str = char(raw');
    fclose(fid);
    rubric = jsondecode(str);
    
    %Go through the structure array (vector) that was created from the
    %jsondecode() call and create problem types.
    %Store these in one vector.
    [~ , col] = size(rubric);
    problems = [];
    for i = 1:col
        problems = [problems , Problem(rubric(i))];
    end
    %The problems output vector should now contain all necessary problems.
    
catch e
    %Check for the errors that could have been thrown in the try block.
    %The first three conditionals check for the unzipping and file status
    %of the solution archive.
    if strcmp(e.identifier, 'AUTOGRADER:UNZIPARCHIVE:INVALIDPATH') %This was taken from the unzipArchive specification.
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','The path is not valid.');
        mE = MException.addCause(e);
        throw(mE);
        
    elseif strcmp(e.identifier, 'AUTOGRADER:UNZIPARCHIVE:INVALIDFILE') %This was taken from the unzipArchive specification.
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','The path is valid but the file is not a valid archive.');
        mE = MException.addCause(e);
        throw(mE);
        
        %Check if the solution file is empty or not.
    elseif fh == -1
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','The path is valid but the solutions are invalid, or the archive does not exist in the path.');
        mE = MException.addCause(e);
        throw(mE);
        
        %This next conditional checks for the decoding of the JSON.
    elseif contains(e.identifier, 'json','IgnoreCase',true)
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','The path is valid, but the solutions are not in a valid JSON format.');
        mE = MException.addCause(e);
        throw(mE);
        %This next conditional checks for issues with the conversion of the
        %problems to the type Problem. 
    elseif strcmp(e.identifier, 'AUTOGRADER:PROBLEM:INVALIDJSON')
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','The path is valid, but the solutions are not in a valid JSON format and could not be converted to the type PROBLEM.');
        mE = MException.addCause(e);
        throw(mE);        
    else
        mE = MException('AUTOGRADER:GENERATESOLUTIONS:INVALIDPATH','There was an error with the generateSolutions method of the autograder.');
        mE = MException.addCause(e);
        throw(mE);
    end
end

end