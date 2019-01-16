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
    fid = fopen('./rubric.json', 'rt');
    if fid == -1
        % work with legacy - if we don't find rubric, look for rubrica/b
        if ~isResubmission
            fid = fopen('./rubrica.json');
        else
            fid = fopen('./rubricb.json');
        end
    end
    json = char(fread(fid)');
    fclose(fid);
    rubric = jsondecode(json);
    % work with legacy - if we don't find rubric, look for rubrica/b

    %Go through the structure array (vector) that was created from the
    %jsondecode() call and create problem types.
    %Store these in one vector.
    progress.Indeterminate = 'off';
    progress.Message = 'Generating Autograder Solutions';
    progress.Value = 0;
    elements = numel(rubric);
    for i = elements:-1:1
        if isempty(rubric(i).supportingFiles)
            rubric(i).supportingFiles = {};
        end
        solutions(i) = Problem(rubric(i));
        progress.Value = min([progress.Value + 1/numel(elements), 1]);
    end
    progress.Indeterminate = 'on';
    %The problems output vector should now contain all necessary problems.

    % Put all testcases in a cell array
    allTestCases = {solutions.testCases};
    % delete any files NOT referenced by any test case
    saveFiles = arrayfun(@(t)([t.supportingFiles(:)', t.loadFiles(:)']), [allTestCases{:}], 'uni', false);
    saveFiles = unique([saveFiles{:}]);
    if ~iscell(saveFiles)
        saveFiles = {};
    end
    % for each file in folder supporting, if not contained in
    % saveFiles, delete
    checkFiles = dir([pwd filesep 'SupportingFiles' filesep]);
    checkFiles(strncmp({checkFiles.name}, '.', 1)) = [];
    for c = 1:numel(checkFiles)
        if ~any(contains([checkFiles(c).folder filesep checkFiles(c).name], saveFiles))
            % delete
            if checkFiles(c).isdir
                [~] = rmdir([checkFiles(c).folder filesep checkFiles(c).name], 's');
            else
                delete([checkFiles(c).folder filesep checkFiles(c).name]);
            end
        end
    end
    
    % Sanity check. Make sure that all files necessary actually exist.
    % for each saveFile, check existence
    mask = ~cellfun(@isfile, saveFiles);
    if any(mask)
        [~, names, exts] = cellfun(@fileparts, saveFiles(mask), 'uni', false);
        files = join([names', exts'], '');
        % throw error; not all files are here
        e = MException('AUTOGRADER:generateSolutions:fileNotFound', ...
            'Supporting File(s) %s not found. Are you sure you put the file(s) in "SupportingFiles"?', ...
            strjoin(files, ', '));
        e.throw();
    end
    % Create vector of indices, s.t. every TestCase when vectorized
    % will have a corresponding index for a Problem
    testCaseIndx = cellfun(@(tc,idx) idx*ones(1,numel(tc)), ...
        allTestCases, num2cell(1:elements), 'uni', false);
    allTestCases = [allTestCases{:}];
    testCaseIndx = [testCaseIndx{:}];

    % Run all testcases with the engine in parallel
    try
        allTestCases = engine(allTestCases);
    catch reason
        e = MException('AUTOGRADER:generateSolutions:engineFailure', ...
            'Engine failed to evaluate test cases; see cause for more information');
        e = e.addCause(reason);
        e.throw();
    end
    % Put the evaluated testcases back
    for i = 1:elements
        solutions(i).testCases = allTestCases(testCaseIndx == i);
    end
end