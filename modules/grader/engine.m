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
%%% Exceptions
%
% An AUTOGRADER:ENGINE:INVALIDRUNNABLE exception is thrown if the input is in an 
% invalid state.
%
% An AUTOGRADER:ENGINE:BADSOLUTION exception is thrown if the input is a solution
% AND that solution errors. The original exception is added to the 
% causes array of the MException.
%
% A TIMEOUT exception will never be thrown, but will be assigned to the 
% Feedback's exception field instead, should the code timeout.
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
%   Threw exception BADSOLUTION, with the original error 
%   in causes.
%
%   % Assume T has not been correctly initialized
%   T;
%   engine(T);
%
%   Threw exception INVALIDRUNNABLE
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
%   which will be the TIMEOUT exception.
%
%   % Assume F is an invalid Feedback;
%   F;
%   engine(F);
%
%   Threw exception INVALIDRUNNABLE   
%
function engine(runnable)

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
    % Copy over supporting files

    % Define static variables (based on TestCase)

    % Record starting point
    
    %% Running
    % Create a new job for the parallel pool
    test = parfeval(@runCase, 0, runnable);
    % Wait until it's finished, up to 30 seconds
    isTimeout = wait(test, 'finished', Student.TIMEOUT);
    % Delete the job
    if isTimeout
        cancel(test);
    end
    delete(test);

    % Populate fields


    %% Cleanup
    % Delete all files mentioned in the files field
    for i = 1:numel(runnable.files)
        % Delete file with name of File
        delete([runnable.files(i).name runnable.files(i).extension]);
    end
    % Close all plots?
    
    % If timeout and TestCase, throw error?
    if isa(runnable, 'TestCase') && isTimeout
        throw(MException('MATLAB:TIMEOUT', 'Solution Code Timed Out'));
    end
end



function runCase(runnable)
    % Setup workspace
    timeout = Timeout();
    cleanup();
    cleaner = onCleanup(@() cleanup(runnable, timeout));

    % Setup the variables
    
    % Run any initializers

    % run the function
    
    timeout.isTimeout = false;
end

function cleanup(runnable, isTimeout)
    % check if runnable is TestCase or Feedback
    fclose('all');
    
    if isa(runnable, 'Feedback')
        if timeout.isTimeout
            runnable.exception = MException('TIMEOUT');
            return;
        end
    else
        if timeout.isTimeout
            e = MException('TIMEOUT');
            throw(e);
        end
    end
end