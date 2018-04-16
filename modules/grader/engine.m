%% engine: Main Engine of the Autograder
%
% The engine function serves as the primary runner of code.
%
% engine(T) runs the code specified by the TestCase T, and assigns the
% outputs, files, and plots to the corresponding fields in T.
%
% engine(F) runs the code specified by the TestCase found in Feedback F,
% and assigns the outputs, files, and plots to the corresponding fields
% in F. This does NOT grade the code, just runs it.
%
%%% Remarks
%
% The engine function is the primary grading mechanism used within the
% the autograder. It provides a "sandboxed" environment for running code,
% and protects against student errors and timeouts.
%
% Timeouts are handled using a parallel pool of workers. In essence, a
% student's code is limited to a certain runtime, 30 seconds by default.
% To change this value, you should edit the TIMEOUT field of the STudent
% class.
%
% Errors in the code itself are handled differently, depending on whether
% a TestCase or a Feedback was passed in.
%
% If a TestCase was received, the error is propogated; this is because a
% solution error is usually a fatal error.
%
% If a Feedback was received, the error is caught and assigned to the
% exception field of the Feedback.
%
% engine uses static checking to check if the function is recursive.
% Calls are traced to the first instance of a call to a built in function.
% For each call to a user-supplied function, that function is checked to see
% if it ever calls itself. Note that it's possible to circumvent this checking
% by having the recursive call within an if statement, like so:
%
%   function notRecurse()
%       if false
%           notRecurse();
%       end
%   end
%
% engine cannot tell that this isn't actually recursive.
%
% Additionally, banned function usage is also statically checked. Calls are
% traced to the first instance of a call to a built in function, just like
% checking for recursion. Each call to a user-defined function results in a
% check for use of banned functions. Note that, just as with recursion checking,
% a "false positive" is possible if code that is unreachable uses a banned function.
%
%   function notBanned()
%       if false
%           bannedFunction();
%       end
%   end
%
% Note that for both recursion and banned functions, comments do not count.
%
% If user created their own version of a banned function, and included it in the file,
% then that is considered to be OK.
%
% Even if the student uses a banned function, the code is still run, and outputs
% still produced.
%
%%% Exceptions
%
% An AUTOGRADER:engine:invalidRunnable exception is thrown if the input is in an
% invalid state.
%
% An AUTOGRADER:engine:invalidSolution exception is thrown if the input is a solution
% AND that solution errors. The original exception is added to the
% causes array of the MException.
%
% A TIMEOUT exception will never be thrown, but will be assigned to the
% Feedback's exception field instead, should the code timeout.
%
%%% Unit Tests
%
%   % Assume T is a valid TestCase that does NOT error.
%   T = TestCase(...);
%   engine(T);
%
%   T now has files, outputs, etc. filled in correctly
%
%   % Assume T is a valid TestCase that errors
%   T = TestCase(...);
%   engine(T);
%
%   Threw exception invalidSolution, with the original error
%   in causes.
%
%   % Assume T has not been correctly initialized
%   T;
%   engine(T);
%
%   Threw exception invalidRunnable
%
%   % Assume F is a valid Feedback with a valid TestCase
%   F = Feedback(...);
%   engine(F);
%
%   F now has files, outputs, etc. filled in correctly
%
%   % Assume F is a valid Feedback that errors
%   F = Feedback(...);
%   engine(F);
%
%   F will have no fields filled in except for points (0) and exception,
%   which will be the exception raised by the student code.
%
%   % Assume F is a valid Feedback that goes into an infinite loop
%   F = Feedback(...);
%   engine(F);
%
%   F will have no fields filled in except for points (0) and exception,
%   which will be the timeout exception.
%
%   % Assume F is an invalid Feedback;
%   F;
%   engine(F);
%
%   Threw exception invalidRunnable
%
function runnable = engine(runnable)

    % For banned functions, we'll need to use static checking, instead of
    % overwriting it in the directory. This is because some functions
    % (like length) are extremely necessary for MATLAB to even function
    % correctly. I would recommend the following:
    %
    %   calls = getcallinfo('FunctionName.m');
    %   calls = [calls.calls];
    %   calls = [calls.fcnCalls];
    %   calls = [calls.names];
    %
    %   Now, calls is cell array of called functions. For each function which
    %   isn't built in, we could walk them recursively, checking for use of the
    %   banned function. Personally, I think that's overkill. This cell array
    %   represents all functions called by any function inside the FunctionName.m
    %   file.

    % This code is divided up into three sections:
    %
    %   1. Setup
    %   2. Running
    %   3. Cleanup
    %
    % Setup sets up the initial call. It cleans up the workspace,
    % sets up the supporting Files.
    %
    % Running defines all late-bound variables and runs the function itself,
    % on a parallel worker. This is done to protect against timeouts. The Feedback
    % or TestCase object is populated here - EVEN IF there is a timeout exception.
    % However, if the TestCase times out, engine should rethrow the timeout error.
    %
    % *NOTE*: Late-bound variables (defined via the initializer) are defined immediately
    % before a function is run. As such, the produced error could be from an initializer.
    % However, this does not cause problems with students, since this error happens
    % during solution code as well.
    %
    % Cleanup cleans up the directory to make it look "pristine" - or at least as it
    % did before. It deletes all files mentioned in the runnable's outputs, and closes
    % all plots.

    %% Setup
    if ~isvalid(runnable)
        e = MException('AUTOGRADER:engine:invalidRunnable', ...
        'Input was not valid');
        throw(e);
    end
    if isa(runnable, 'TestCase')
        tCase = runnable;
    elseif isa(runnable, 'Feedback')
        tCase = runnable.testCase;
    else
        e = MException('AUTOGRADER:engine:invalidRunnable', ...
        'Input was not of class Runnable');
        throw(e);
    end

    % Copy over supporting files
    supportingFiles = tCase.supportingFiles;
    origPath = cd(runnable.path);
    [~, ~, func] = parseFunction(tCase.call);

    allCalls = getcallinfo([func2str(func) '.m']);
    calls = [allCalls.calls];
    calls = [calls.fcnCalls];
    calls = [calls.names];

    % Test for recursion. If any function calls itself, good to go.
    if isa(runnable, 'Feedback')
        runnable.isRecursive = checkRecur(allCalls, func2str(func));
    end

    bannedFunctions = tCase.banned;
    for i = 1:numel(bannedFunctions)
        if any(strcmpi(calls, bannedFunctions{i}))
            if isa(runnable, 'TestCase')
                throw(MException('AUTOGRADER:engine:invalidSolution', ...
                    'Solution uses banned functions'));
            else
                runnable.exception = MException('AUTOGRADER:engine:banned', ...
                    'File used banned function %s.', bannedFunctions{i});
                return;
            end
        end
    end

    for i = 1:numel(supportingFiles)
        copyfile(supportingFiles{i});
        [~, supportingFiles{i}, ext] = fileparts(supportingFiles{i});
        supportingFiles{i} = [supportingFiles{i}, ext];
    end
    % Record starting point
    beforeSnap = dir();
    beforeSnap = {beforeSnap.name};
    beforeSnap(strncmp(beforeSnap, '.', 1)) = [];

    % Load data, load into cell
    loads = cell(size(tCase.loadFiles));
    for i = 1:numel(tCase.loadFiles)
        % throw away result
        loads{i} = load(tCase.loadFiles{i});
    end
    % Collapse into cell array of names and cell array of values
    numVars = 0;
    for i = 1:numel(loads)
        numVars = numVars + numel(fieldnames(loads{i}));
    end
    varNames = cell(1, sum(numVars));
    varValues = cell(1, sum(numVars));
    counter = 1;
    for i = 1:numel(loads)
        valNames = fieldnames(loads{i});
        for val = 1:numel(valNames)
            varNames{counter} = valNames{val};
            varValues{counter} = loads{i}.(valNames{val});
            counter = counter + 1;
        end
    end
    % Save original loadFile names and assign vars to loadFiles field
    origFileNames = tCase.loadFiles;
    tCase.loadFiles = [varNames; varValues];
    %% Running
    % Create a new job for the parallel pool
    test = parfeval(@runCase, 1, runnable);

    % Wait until it's finished, up to 30 seconds
    isTimeout = ~wait(test, 'finished', Student.TIMEOUT);
    % Delete the job
    if isTimeout
        cancel(test);
        runnable.exception = MException('AUTOGRADER:timeout', 'Timeout occurred');
    else
        runnable = test.fetchOutputs();
    end
    tCase.loadFiles = origFileNames;
    if isa(runnable, 'TestCase')
        tCase = runnable;
    else
        tCase = runnable.testCase;
    end
    delete(test);

    % Populate files, plots
    afterSnap = dir();
    afterSnap = {afterSnap.name};
    afterSnap(strncmp(afterSnap, '.', 1)) = [];

    addedFiles = sort(setdiff(afterSnap, beforeSnap));

    populateFiles(runnable, addedFiles);
    populatePlots(runnable);
    %% Cleanup
    % Delete all files mentioned in the files field
    for i = 1:numel(runnable.files)
        % Delete file with name of File
        delete([runnable.files(i).name runnable.files(i).extension]);
    end

    % Delete all files that were marked as supporting files
    for i = 1:numel(supportingFiles)
        delete(supportingFiles{i});
    end

    % Close all figures with visible handles?
    figs = findobj(0, 'type', 'figure');
    delete(figs);
    tCase.loadFiles = origFileNames;
    cd(origPath);
    % If timeout and TestCase, throw error
    if isa(runnable, 'TestCase') && isTimeout
        throw(MException('MATLAB:timeout', 'Solution Code Timed Out'));
    end
end

function populateFiles(runnable, addedFiles)
    % Get last file first to prealloc array
    if numel(addedFiles) ~= 0
        files(numel(addedFiles)) = File([pwd() filesep() addedFiles{end}]);
        % Iterate over all files (including last one again) so that _soln
        % can be removed if necessary
        for i = 1:numel(addedFiles)
            files(i) = File([pwd() filesep() addedFiles{i}]);
            if isa(runnable, 'TestCase')
                % Remove _soln from name
                files(i).name = strrep(files(i).name, '_soln', '');
            end
        end
        runnable.files = files;
    end
end

function populatePlots(runnable)
    % Get all handles; since the Position is captured, that can be used
    % for the subplot checking
    pHandles = findobj(0, 'type', 'axes');
    if numel(pHandles) ~= 0
        plots(numel(pHandles)) = Plot(pHandles(end));
        for i = 1:(numel(pHandles) - 1)
            plots(i) = Plot(pHandles(i));
        end

        runnable.plots = plots;
    end
end


function runnable = runCase(runnable)
    % Setup workspace
    % is this supposed to be here?  -->     cleanup();
    cleaner = onCleanup(@() cleanup());

    if isa(runnable, 'TestCase')
        tCase = runnable;
    else
        tCase = runnable.testCase;
    end
    if ~isempty(tCase.initializer)
        % Append initializer call to end of varDefs
        % Make sure suppressed!
        if tCase.initializer(end) ~= ';'
            tCase.initializer = [tCase.initializer ';'];
        end
        init = tCase.initializer;
    else
        init = '';
    end

    % Parse the call
    origPath = cd(runnable.path);
    [inNames, outNames, func] = parseFunction(tCase.call);
    outs = cell(size(outNames));
    % run the function
    % create sentinel file
    fid = fopen(File.SENTINEL, 'r');
    try
        [outs{:}] = runner(func, init, inNames, tCase.loadFiles);
    catch e
        if isa(runnable, 'TestCase')
            rethrow(e);
        else
            runnable.exception = e;
        end
    end
    cd(origPath);
    name = fopen(fid);
    fclose(fid);
    if ~strcmp(name, File.SENTINEL)
        % Communicate that user called fclose all.
        if isa(runnable, 'Feedback')
            runnable.exception = MException('AUTOGRADER:fcloseAll', 'Student Code called fclose all');
        end
    end
    % Populate outputs
    % outNames is in order of argument. For each outName, apply corresponding
    % value
    for i = 1:numel(outs)
        runnable.outputs.(outNames{i}) = outs{i};
    end
end

function varargout = runner(func____, init____, ins, loads____)

    % Create statement that becomes cell array of all inputs.
    % No input sanitization here because all input names have already
    % been checked.
    inCell____ = ['{' strjoin(ins, ',') '}'];
    % varargout becomes cell array of the size of number of args requested
    varargout = cell(1, nargout);
    % Load MAT files
    for i____ = 1:size(loads____, 2)
        eval([loads____{1, i____} ' = loads____{2, ' num2str(i____) '};']);
    end
    % Run initializer, if any
    if ~isempty(init____)
        eval(init____);
    end
    % Create true cell array of inputs to use in func
    ins____ = eval(inCell____);
    % Run func
    [varargout{:}] = func____(ins____{:});
end

%% parseFunction: Parse function call
%
% Parses the function call for inputs, outputs, and the function handle.
%
% [I, O, F] = parseFunction(C) will parse the function call C and
% return the input names in I, the output names in O, and the function
% handle in F.
%
%%% Remarks
%
% This function is unaffected by any type of white space.
%
% This function is case sensitive
%
%%% Unit Tests
% Unlike ordinary Unit Tests, this is a list of tests. P means passing, U
% means unknown.
%
% * P |'myFun'| -> [{}, {}, @myFun]
% * P |'myFun;'| -> [{}, {}, @myFun]
% * P |'myFun()'| -> [{}, {}, @myFun]
% * P |'myFun();'| -> [{}, {}, @myFun]
% * P |'myFun(in)'| -> [{'in'}, {}, @myFun]
% * P |'myFun(in);'| -> [{'in'}, {}, @myFun]
% * P |'myFun(in,in2)'| -> [{'in', 'in2'}, {}, @myFun]
% * P |'myFun(in,In2);'| -> [{'in', 'In2'}, {}, @myFun]
% * P |'[] = myFun'| -> [{}, {}, @myFun]
% * P |'[] = myFun;'| -> [{}, {}, @myFun]
% * P |'[] = myFun()'| -> [{}, {}, @myFun]
% * P |'[] = myFun();'| -> [{}, {}, @myFun]
% * P |'[] = myFun(in)'| -> [{'in'}, {}, @myFun]
% * P |'[] = myFun(in);'| -> [{'in'}, {}, @myFun]
% * P |'[] = myFun(in1,in2)'| -> [{'in1', 'in2'}, {}, @myFun]
% * P |'[] = myFun(in1,in2);'| -> [{'in1', 'in2'}, {}, @myFun]
% * P |'[a] = myFun'| -> [{}, {'a'}, @myFun]
% * P |'[a] = myFun;'| -> [{}, {'a'}, @myFun]
% * P |'[a] = myFun()'| -> [{}, {'a'}, @myFun]
% * P |'[a] = myFun();'| -> [{}, {'a'}, @myFun]
% * P |'[a] = myFun(in)'| -> [{'in'}, {'a'}, @myFun]
% * P |'[a] = myFun(in);'| -> [{'in'}, {'a'}, @myFun]
% * P |'[a] = myFun(in1,in2)'| -> [{'in1', 'in2'}, {'a'}, @myFun]
% * P |'[a] = myFun(in1,in2);'| -> [{'in1', 'in2'}, {'a'}, @myFun]
% * P |'a = myFun'| -> [{}, {'a'}, @myFun]
% * P |'a = myFun;'| -> [{}, {'a'}, @myFun]
% * P |'a = myFun()'| -> [{}, {'a'}, @myFun]
% * P |'a = myFun();'| -> [{}, {'a'}, @myFun]
% * P |'a = myFun(in)'| -> [{'in'}, {'a'}, @myFun]
% * P |'a = myFun(in);'| -> [{'in'}, {'a'}, @myFun]
% * P |'a = myFun(in1, in2)'| -> [{'in1', 'in2'}, {'a'}, @myFun]
% * P |'a = myFun(in1, in2);'| -> [{'in1', 'in2'}, {'a'}, @myFun]
% * P |'[a,b] = myFun'| -> [{}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun;'| -> [{}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun()'| -> [{}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun();'| -> [{}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun(in)'| -> [{'in'}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun(in);'| -> [{'in'}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun(in1, in2)'| -> [{'in1', 'in2'}, {'a', 'b'}, @myFun]
% * P |'[a,b] = myFun(in1, in2);'| -> [{'in1', 'in2'}, {'a', 'b'}, @myFun]
%
function [ins, outs, func] = parseFunction(call)
    % Strip start, ending space:
    call = strip(call);
    % if end is ; get rid of it (doesn't actually affect anything, but why not)
    call(call == ';') = '';
    % For inputs, look for starting paren. If not found, no inputs
    ins = regexp(call, '(?<=\()([^)]+)(?=\))', 'match');
    if ~isempty(ins)
        ins = ins{1};
        ins = regexprep(ins, '\s+', '');
        ins = strsplit(ins, ',');
    end

    % For outputs, look for an equal sign. No equal sign, no outputs
    if ~contains(call, '=')
        outs = {};
    else
        % if no bracket found, only one output. Grab accordingly
        if ~contains(call, ']')
            call(call == ' ') = '';
            outs = regexp(call, '^[^\=]*', 'match');
        else
            % We have brackets; find in between and engage
            outs = regexp(call, '(?<=\[)([^\]]+)(?=\])', 'match');
            if ~isempty(outs)
                outs = strip(outs{1});
                % 'Replace all white space with commas'
                outs = regexprep(outs, '\s+', ',');
                outs = strsplit(outs, {','});
            end
        end
    end

    % For function name, strip everything before possible =, everything
    % after possible (.
    if contains(call, '=')
        ind = strfind(call, '=');
        call(1:ind) = '';
    end
    if contains(call, '(')
        ind = strfind(call, '(');
        call(ind:end) = '';
    end
    func = str2func(strip(call));

end

function cleanup()
    % check if runnable is TestCase or Feedback
    fclose('all');
end


function isRecurring = checkRecur(callInfo, main)
    % Check if this function calls itself. If so, exit true.
    % If not, check all functions it calls:
    %   If the call is to a builtin, don't investigate
    %   If the call is to something NOT builtin, investigate!

    % First, check calls for itself.
    mainCall = callInfo(strcmp({callInfo.name}, main));
    if any(strcmp(mainCall.name, mainCall.calls.innerCalls.names))
        % true. Exit
        isRecurring = true;
        return;
    end

    % look at all functions in callInfo that aren't us
    calls = callInfo(~strcmp({callInfo.name}, main));
    for i = 1:numel(calls)
        if checkRecur(calls(i), calls(i).name)
            isRecurring = true;
            return;
        end
    end

    % Iterate over external calls.
    external = mainCall.calls.fcnCalls.names;
    % check local directory for filenames. If not there, builtin!
    possCalls = dir('**/*.m');
    possCalls = cellfun(@(n)(n(1:(end-2))), {possCalls.name}, 'uni', false);
    for i = 1:numel(external)
        % if external isn't found anywhere in possCalls, don't engage
        if any(strcmp(external{i}, possCalls))
            extCallInfo = getcallinfo([external{i} '.m']);
            if checkRecur(extCallInfo, external{i})
                isRecurring = true;
                return;
            end
        end
    end

    isRecurring = false;
end