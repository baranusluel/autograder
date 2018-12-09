%% engine: Main Engine of the Autograder
%
% The engine function serves as the primary runner of code.
%
% R = engine(R) runs the code specified by the TestCase found in Runnable R,
% and assigns the outputs, files, and plots to the corresponding fields
% in F. This does NOT grade the code, just runs it. You must capture the
% outputs; the engine does NOT modify the inputs. The output is the same
% size as the inputs
%
%%% Remarks
%
% For multiple runnables, the engine will wait until all of them have
% finished, or timed out. However, other than that, there is no requirement
% that any of them be related to each other - they are all run in parallel.
%
% While it will always be faster to run runnables in parallel, there are no
% guarantees about timing or order. If you need a specific order, you must
% run them individually.
%
% The engine function is the primary grading mechanism used within the
% the autograder. It provides a "sandboxed" environment for running code,
% and protects against student errors and timeouts.
%
% The student's code is copied to a new folder, and all supporting files
% are also copied over. It is guaranteed that, though the students are run
% in parallel, no student's code can ever affect another student's code.
%
% Timeouts are handled using a parallel pool of workers. In essence, a
% student's code is limited to a certain runtime, 30 seconds by default.
% To change this value, you should edit the TIMEOUT field of the Student
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
% if it ever calls itself or anything up the stack. Mutual Recursion is
% checked. Note that it's possible to circumvent this checking
% by having the recursive call within an if statement, like so:
%
%   function notRecurse()
%       if false
%           notRecurse();
%       end
%   end
%
% engine cannot tell that this isn't actually recursive, since it's not
% known until runtime that if false will never actually be true.
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
%   F = []; % assume F is a vector of Feedbacks
%   A = engine(F);
%
%   A is a vector of finished runnables.
%
function runnables = engine(runnables)

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
    BANNED = {'parpool', 'gcp', 'parfeval', 'send', 'fetchOutputs', ...
        'cancel', 'parfevalOnAll', 'fetchNext', 'batch', ...
        'eval', 'feval', 'assignin', 'evalc', 'evalin', ...
        'input', 'wait', 'uiwait', 'keyboard', 'dbstop', 'dos', 'unix', ...
        'cd', 'system', 'restoredefaultpath', 'builtin', 'load', ...
        'edit', 'copyfile', 'movefile', 'dir', 'ls', 'mkdir', 'rmdir', ...
        'perl', 'fileattrib', 'delete', 'exit', 'quit', 'dbstack', ...
        'webread', 'webwrite', 'websave', 'web', 'tcpip',  ...
        'urlread', 'urlwrite', 'weboptions', 'ftp', 'mget', ...
        'sound', 'soundsc', 'audiorecorder', 'audioplayer', ...
        'addpath', 'rmpath', 'path', 'gzip', 'gunzip', 'tar', 'untar', ...
        'open', 'zip', 'unzip', 'set', 'get', 'settings', 'winopen', ...
        };
    DIARY_LENGTH = 1000;

    if any(~isvalid(runnables))
        e = MException('AUTOGRADER:engine:invalidRunnable', ...
            'Input were not valid runnables');
        e.throw();
    end
    if isempty(runnables)
        return;
    end
    if isa(runnables, 'TestCase')
        isTestCase = true;
    elseif isa(runnables, 'Feedback')
        isTestCase = false;
    else
        throw(MException('AUTOGRADER:engine:invalidRunnable', ...
            'Input was not a runnable type'));
    end
    origPaths = cell(size(runnables));
    for r = 1:numel(runnables)
        runnable = runnables(r);
        fld = tempname;
        mkdir(fld);
        if isTestCase
            tCase = runnable;
        else
            tCase = runnable.testCase;
        end
        % copy the student's files to fld
        copyfile([runnable.path filesep '*.m'], fld);
        origPaths{r} = runnable.path;
        runnable.path = fld;
        
        % check validity of student code
        info = mtree([origPaths{r} filesep tCase.name '.m'], '-file');
        if ~info.isnull && info.allkind('ERR')
            if isa(runnable, 'Feedback')
                runnable.exception = MException('AUTOGRADER:syntaxError', ...
                    info.select(1).string);
            else
                e = MException('AUTOGRADER:syntaxError', ...
                    info.select(1).string);
                e.throw;
            end
        end
        % check recursion
        if ~isTestCase
            runnable.isRecursive = checkRecur([origPaths{r} filesep tCase.name '.m']);
        end
        % check banned usage
        if ~isTestCase && isempty(runnable.exception)
            [isBanned, bannedFunName] = checkBanned([tCase.name '.m'], [BANNED tCase.banned(:)'], origPaths{r});
            if isBanned
                runnable.exception = MException('AUTOGRADER:engine:banned', ...
                    'File used banned function(s): %s', bannedFunName);
            end
        end
        if isTestCase || isempty(runnable.exception)
            % copy over supporting files
            for s = 1:numel(tCase.supportingFiles)
                copyfile(tCase.supportingFiles{s}, runnable.path);
            end

            % Load the data
            if isTestCase
                loads = cell(size(tCase.loadFiles));
                for l = 1:numel(tCase.loadFiles)
                    loads{l} = load(tCase.loadFiles{l});
                end
                numVars = 0;
                for l = 1:numel(loads)
                    numVars = numVars + numel(fieldnames(loads{l}));
                end
                varNames = cell(1, numVars);
                varValues = cell(1, numVars);
                counter = 1;
                for l = 1:numel(loads)
                    valNames = fieldnames(loads{l});
                    for val = 1:numel(valNames)
                        varNames{counter} = valNames{val};
                        varValues{counter} = loads{l}.(valNames{val});
                        counter = counter + 1;
                    end
                end
                % save the original load files
                tCase.inputs = [varNames; varValues];
            end
            if ~isTestCase
                runnable.testCase = tCase;
            else
                runnable = tCase;
            end
        end
        runnables(r) = runnable;
    end
    % done with parfor - now run all the cases!
    for w = numel(runnables):-1:1
        if ~isTestCase && ~isempty(runnables(w).exception)
            workers(w) = parfeval(@()(false), 0);
            delete(workers(w));
        else
            workers(w) = parfeval(@runCase, 1, runnables(w), pwd);
        end
    end
    while any(isvalid(workers))
        for w = 1:numel(workers)
            % check the status. If running, that's a timeout!
            worker = workers(w);
            % check status. If it's finished, get outputs and delete
            if isvalid(worker)
                now = datetime;
                now.TimeZone = worker.CreateDateTime.TimeZone;
                % first, try to get the diary. If we can't, this means that
                % they did not suppress!!
                try
                    if strcmp(worker.State, 'finished')
                        % check error
                        if ~isempty(worker.Error) && isTestCase
                            % test Case; throw error
                            e = MException('AUTOGRADER:engine:testCaseFailure', ...
                                'TestCase failed, see error for more information');
                            e = e.addCause(worker.Error.remotecause{1});
                            e.throw();
                        elseif ~isempty(worker.Error) && ~isTestCase
                            e = MException('AUTOGRADER:studentError', ...
                                'Student Code errored');
                            if isempty(worker.Error.remotecause)
                                % for now, it seems that opening infinite
                                % files for reading causes it to error without
                                % a cause. So the cause should be
                                % InfiniteOpenFiles.
                                if length(worker.Diary) > DIARY_LENGTH
                                    e = MException('AUTOGRADER:studentError', ...
                                        'Student Code errored');
                                    runnables(w).exception = ...
                                        e.addCause(MException('AUTOGRADER:engine:noSuppression', ...
                                        'Student code did not suppress output and overflowed the command window'));
                                else
                                    runnables(w).exception = ...
                                        e.addCause(MException('AUTOGRADER:engine:tooManyOpenFiles', ...
                                        'You opened too many files'));
                                end
                            else
                                runnables(w).exception = ...
                                    e.addCause(worker.Error.remotecause{1});
                            end
                        else
                            runnables(w) = worker.fetchOutputs();
                        end
                        delete(worker);
                    elseif ~isempty(worker.StartDateTime) && (now - worker.StartDateTime > seconds(Student.TIMEOUT))
                        cancel(worker);
                        delete(worker);
                        if ~isTestCase
                            runnables(w).exception = ...
                                MException('AUTOGRADER:timeout', 'Timeout occurred');
                        else
                            e = MException('AUTOGRADER:engine:testCaseFailure', ...
                                'TestCase timed out');
                            e = e.addCause(MException('AUTOGRADER:timeout', 'Timeout occurred'));
                            e.throw();
                        end
                    end
                catch reason
                    % did not suppress! cancel and set the exception
                    if strcmpi(reason.identifier, 'MATLAB:Java:GenericException')
                        if isTestCase
                            workers.cancel;
                            e = MException('AUTOGRADER:engine:testCaseFailure', ...
                                'TestCase failed, likely printed too much to the command window. See error for more information');
                            e.addCause(reason);
                            e.throw();
                        else
                            worker.cancel;
                            delete(worker);
                            e = MException('AUTOGRADER:studentError', ...
                                'Student Code errored');
                            runnables(w).exception = ...
                                e.addCause(MException('AUTOGRADER:engine:noSuppression', ...
                                'Student code did not suppress output and overflowed the command window'));
                        end
                    else
                        reason.rethrow;
                    end
                end
            end
        end
    end
    % reset each runnable
    for r = 1:numel(runnables)
        % remove path
        [~] = rmdir(runnables(r).path, 's');
        runnables(r).path = origPaths{r};
    end
end

function populateFiles(runnable, beforeSnap)
    afterSnap = dir(runnable.path);
    afterSnap = {afterSnap.name};
    afterSnap(strncmp(afterSnap, '.', 1)) = [];

    addedFiles = sort(setdiff(afterSnap, beforeSnap));
    % Get last file first to prealloc array
    if numel(addedFiles) ~= 0
        % Iterate over all files (including last one again) so that _soln
        % can be removed if necessary
        for i = numel(addedFiles):-1:1
            files(i) = File([runnable.path filesep addedFiles{i}]);
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


function runnable = runCase(runnable, safeDir)
    % Setup workspace
    builtin('cd', safeDir);
    cleaner = onCleanup(@()(cleanup(safeDir)));
    beforeSnap = dir(runnable.path);
    beforeSnap = {beforeSnap.name};
    beforeSnap(strncmp(beforeSnap, '.', 1)) = [];
    if isa(runnable, 'TestCase')
        tCase = runnable;
    else
        tCase = runnable.testCase;
    end

    % run the function
    % create sentinel file
    fid = fopen([mfilename('fullpath') '.m'], 'r');
    try
        rng(1);
        cd(runnable.path);
        outs = cell(size(tCase.outputNames));
        [outs{:}] = runner(str2func(tCase.name), ...
            tCase.inputNames, ...
            tCase.inputs);
    catch e
        if isa(runnable, 'TestCase')
            e.rethrow();
        else
            me = MException('AUTOGRADER:studentCodeError', ...
                'Student Code Errored');
            me = me.addCause(e);
            runnable.exception = me;
            return;
        end
    end
    builtin('cd', safeDir);
    ids = fopen('all');
    if isempty(ids)
        if isa(runnable, 'Feedback')
            runnable.exception = MException('AUTOGRADER:fcloseAll', 'Student Code called fclose all');
        else
            throw(MException('AUTOGRADER:fcloseAll', 'Test Case Code called fclose all'));
        end
    end
    fclose(fid);
    ids = fopen('all');
    if ~isempty(ids)
        if isa(runnable, 'Feedback')
            runnable.exception = MException('AUTOGADER:fileNotClosed', 'Student Code did not close all its files');
        else
            throw(MException('AUTOGADER:fileNotClosed', 'Test Case Code did not close all its files'));
        end
    end
    % Populate outputs
    % outNames is in order of argument. For each outName, apply corresponding
    % value
    for i = 1:numel(outs)
        runnable.outputs.(tCase.outputNames{i}) = outs{i};
    end
    populateFiles(runnable, beforeSnap);
    populatePlots(runnable);
end

function varargout = runner(func____, ins, loads____)

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
    % Create true cell array of inputs to use in func
    ins____ = eval(inCell____);
    % Run func
    [varargout{:}] = func____(ins____{:});
end

function cleanup(origPath)
    builtin('cd', origPath);
    fclose('all');

    h = findall(0, 'type', 'figure');
    close(h, 'force');
    delete(h);
end