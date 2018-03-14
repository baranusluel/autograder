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
% Engine is run with a TestCase argument when running solution functions.
% It is run with a Feedback argument when running student functions.
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


end