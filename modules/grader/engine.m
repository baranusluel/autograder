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
% An AUTOGRADER:ENGINE:INVALIDRUNNABLE is thrown if the input is either
% not a Runnable object OR if the input is in an invalid state.
%
%%% Unit Tests
%
%   % Assume T is a valid TestCase that does NOT error.
%   T = TestCase(...);
%   engine(T);
%
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