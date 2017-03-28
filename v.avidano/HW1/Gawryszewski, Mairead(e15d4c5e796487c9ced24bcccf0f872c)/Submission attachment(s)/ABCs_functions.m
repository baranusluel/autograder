% DO NOT CHANGE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, B, C, D, E, F, G, H, I, J, K] = ABCs_functions()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Answer the following statements by setting the variables immediately
% following the questions with either the words 'true' or 'false' (without
% the single quotes). Note that MATLAB understands the meaning of these
% particular key words by default. This will be important later in the
% semester.

% Example.  Professor HB teaches CS 1371.
% example = true;

%--------------------------------------------------------------------------
%Part I. Functions

% Functions have their own scope; that is, variables that are defined
% inside a function cannot not access the workspace in which the function 
% is run.
A = true;

% By default, functions that I write will work even if they are not in my
% current directory.
B = false;

%--------------------------------------------------------------------------
% Part II. Function Headers. For the following function headers, answer
% true if they are valid, false otherwise.

% function myFunc = [in1, in2]
C = false;

% function out = myFunc
D = true;

% function [out two three] = myFunc(in)
E = true;

% function [out] = myFunc(out)
F = true;

% function (out two) = myFunc[in]
G = false;

% function [out out2] = myFunc(in in2);
H = false;

%--------------------------------------------------------------------------
% Part III. Function Scope

% If I have a valid function "myFunc" with the header:
%
%               function [out1 out2] = myFunc(in)
%
% and I call [a b] = myFunc(13) from the command line:

% Is "a" defined in my workspace (have I assigned it a value in the
% workspace)?
I = true;

% Is "out2" defined in my workspace?
J = false;

% Is "in" defined in my workspace?
K = false;

end