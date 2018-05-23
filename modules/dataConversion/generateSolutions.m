%% generateSolutions: Generate the solution values for comparison
%
% This will generate the solution values, given a logical value. These solutions are held in a `Problem` array.
%
% P = generateSolutions(R, B) will return a Problem Array P containing
% the problems for the current homework. It uses |rubrica| if R is false;
% otherwise, it will use |rubricb|. Additionally, it will attempt to update
% the progress bar B.
%
%%% Remarks
%
% Any exceptions thrown by the Problem class or sub classes will not be
% caught by generateSolutions, and will instead by propogated forward.
% These errors are considered mostly fatal.
%
% The JSON format is strictly enforced. For more information on what
% this format should look like, see the central documentation.
%
%%% Exceptions
%
% generateSolutions throws exception
% AUTOGRADER:generateSolutions:invalidInput if the input is not of type
% logical.
%
% generateSolutions throws exception
% AUTOGRADER:generateSolutions:invalidPath if the path (solutions) are not
% valid.
%
%%% Unit Tests
%
%   R = true
%   P = generateSolutions(R);
%
%   P -> Valid Problem Array
%
%   R = ''; % Invalid Input
%   P = generateSolutions(R);
%
%   Threw invalidInput exception
%
%   R = true; % Valid input, invalid solutions!
%   P = generateSolutions(R);
%
%   TestCase Threw exception <solnException>
%
%   R = false; % Valid input, but incomplete archive
%   P = generateSolutions(R);
%
%   Threw invalidPath exception
%
function solutions = generateSolutions(isResubmission, progress)
%try-catch block to catch any resulting errors.
try
    %Archive is already unzipped.
    %Decode the JSON
    if islogical(isResubmission)
        if ~isResubmission
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
        progress.Indeterminate = 'off';
        progress.Message = 'Generating Autograder Solutions';
        progress.Value = 0;
        elements = numel(rubric);
        for i = elements:-1:1
            solutions(i) = Problem(rubric(i));
            progress.Value = min([progress.Value + 1/numel(elements), 1]);
        end
        progress.Indeterminate = 'on';
        %The problems output vector should now contain all necessary problems.

        % Put all testcases in a cell array
        allTestCases = {solutions.testCases};
        % delete any files NOT referenced by any test case
        saveFiles = arrayfun(@(t)([t.supportingFiles{:}, t.loadFiles{:}]), [allTestCases{:}], 'uni', false);
        % for each file in folder supporting, if not contained in
        % saveFiles, delete
        checkFiles = dir([pwd filesep 'SupportingFiles' filesep]);
        checkFiles(strncmp({checkFiles.name}, '.', 1)) = [];
        for c = 1:numel(checkFiles)
            if ~any(contains([checkFiles(c).folder filesep checkFiles(c).name], saveFiles))
                % delete
                delete([checkFiles(c).folder filesep checkFiles(c).name]);
            end
        end
        % Create vector of indices, s.t. every TestCase when vectorized
        % will have a corresponding index for a Problem
        testCaseIndx = cellfun(@(tc,idx) idx*ones(1,numel(tc)), ...
            allTestCases, num2cell(1:elements), 'uni', false);
        allTestCases = [allTestCases{:}];
        testCaseIndx = [testCaseIndx{:}];

        % Run all testcases with the engine in parallel
        allTestCases = engine(allTestCases);
        % Put the evaluated testcases back
        for i = 1:elements
            solutions(i).testCases = allTestCases(testCaseIndx == i);
        end
        
    else
        mE = MException('AUTOGRADER:generateSolutions:invalidInput','The input is not of type logical for isResubmission.');
        throw(mE);
    end

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
            case 'AUTOGRADER:generateSolutions:invalidInput'
                %This checks if the input is a logical or not.
                mE = MException('AUTOGRADER:generateSolutions:invalidInput','The input is not of type logical for isResubmission.');
                mE = mE.addCause(e);
                throw(mE);
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