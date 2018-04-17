%% generateSolutions: Generate the solution values for comparison 
%   
% This will generate the solution values, given a logical value. These solutions are held in a `Problem` array.
%
% PROBLEMS = generateSolutions(isResubmission) will return a Problem Array containing
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
% AUTOGRADER:generateSolutions:invalidPath if the input path is invalid
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
%   Threw invalidPath exception
%
%   PATH = 'C:\Users\...\Soln.zip'; % Valid path, invalid solutions!
%   PROBLEMS = generateSolutions(PATH);
%
%   TestCase Threw exception <solnException>
%
%   PATH = 'C:\Users\...\Soln.zip'; % Valid path, but incomplete archive
%   PROBLEMS = generateSolutions(PATH);
%
%   Threw invalidPath exception
%
function solutions = generateSolutions(isResubmission)
%try-catch block to catch any resulting errors.
try
    %Archive is already unzipped.
    %Decode the JSON
    if isResubmission
        fh = fopen('rubrica.json','rt');
        json = char(fread(fh)');
        fclose(fh);
        rubric = jsondecode(json);
    else
        fh = fopen('rubricb.json','rt');
        json = char(fread(fh)');
        fclose(fh);
        rubric = jsondecode(json);
    end
    
    %Go through the structure array (vector) that was created from the
    %jsondecode() call and create problem types.
    %Store these in one vector.
    elements = numel(rubric);
    for i = elements:-1:1
        solutions(i) = Problem(rubric(i));
    end
    %The problems output vector should now contain all necessary problems.
    
catch e
    %Check for the errors that could have been thrown in the try block.
    %The first three conditionals check for the unzipping and file status
    %of the solution archive.
    
    %Check if the solution file is empty or not.
    if fh == -1
        mE = MException('AUTOGRADER:generateSolutions:invalidPath','The path is valid, but the solutions could not be parsed (Perhaps the solutions are not valid, or the archive is unreadable?)');
        mE = mE.addCause(e);
        throw(mE);
    else
        %This next conditional checks for the decoding of the JSON.
        switch e.identifier
            case 'AUTOGRADER:problem:invalidJSON'
                %This checks for issues with the conversion of the
                %problems to the type Problem.
                mE = MException('AUTOGRADER:generateSolutions:invalidPath','The path is valid, but the solutions are not in a valid JSON format and could not be converted to the type PROBLEM.');
                mE = mE.addCause(e);
                throw(mE);
            otherwise
                mE = MException('AUTOGRADER:generateSolutions:invalidPath','There was an error with the generateSolutions method of the autograder.');
                mE = mE.addCause(e);
                throw(mE);
        end
    end
    
end
end