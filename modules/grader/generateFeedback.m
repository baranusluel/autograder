%% generateFeedback: Generate HTML feedback for primitives
%
% |generateFeedback| makes presentation-ready HTML that depicts how the 
% student's primitive result compares to the solution's primitive result.
%
% HTML = generateFeedback(SOLN, STUD) will generate HTML encoded feedback, 
% given the student's result and the solution's result. Both must be given, 
% but empty is a valid input for either.
%
%%% Remarks
%
% generateFeedback deals only with "primitive" values. This means 
% the type of the given values must be one of the following:
%
% * |double|
%
% * |single|
%
% * |uint8|, |uint16|, |uint32|, |uint64|
%
% * |int8|, |int16|, |int32|, |int64|
%
% * |char|
%
% * |string|
%
% * |cell|
%
% * |struct|
%
% * |logical|
%
% Note that |NaN| is considered equal to |NaN|; ie, |NaN == NaN = true|.
% This is different from isequal, and instead follows isequaln.
%
% |generateFeedback| first checks to see they are |isequaln|. If they are, 
% |PASSING| is returned. Otherwise, generateFeedback will first check 
% each value's class. If they differ, a |DIFF_CLASS| is returned. Otherwise,
% depending on the class, a visualization of the difference between the given 
% arguments is returned. The return value will always have the check mark 
% (|PASSING|) or the red x (|INCORRECT|).
%
% For values of type |cell| or |struct|, the first difference is shown. 
% To show this difference, generateFeedback uses that type's default comparison
% method. If it's a primitive, it returns the difference representation by 
% using generateFeedback; otherwise, it uses the type's comparison method.
%
%%% Exceptions
%
% generateFeedback is guarunteed to never throw an exception, 
% as long as two arguments are given.
%
%%% Unit Tests
%
%   S = [];
%   P = [];
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = NaN;
%   P = NaN;
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = 1;
%   P = S;
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = 'Hello world';
%   P = 1;
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> char class expected; double class given.</p>'
%
%   S = uint8(1);
%   P = double(1);
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> uint8 class expected; double class given.</p>'
%
%   S = 1;
%   P = 2;
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> 1 expected; 2 given.</p>'
%
%   S = "Hello World"
%   P = "Goodbye World"
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> "Hello World" expected; "Goodbye World" given.</p>'
%
%   S = true;
%   P = false;
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> true expected; false given.</p>'
%
%   S = [1 2 3];
%   P = [1; 2; 3];
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> Dimension Mismatch: Expected 1x3; 3x1 given.</p>'
%
%   S = {1, 2, 3};
%   P = {1, 3, 2};
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> At index (1, 2): 2 expected; 3 given.</p>'
%
%   S = struct('hello', 1, 'world', {1, 2, 3});
%   P = struct('hello', 2, 'world', {3, 2, 1});
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> In field "hello": expected 2; one given. There may be other differences.</p>'
%
%   S = struct('hello', 1, 'world', {1, 2, 3});
%   P = struct('hello', 1, 'world', {3, 2, 1});
%   HTML = generateFeedback(S, P);
%
%   HTML -> '<p><span class="fas fa-times"></span> In field "world": At index (1): 1 expected; 3 given. There may be other differences.</p>'

% Note that there are a variety of constants, which are listed below:
%
% * |PASSING = '<span class="fas fa-check></span>'|
% * |INCORRECT = '<span class="fas fa-times"></span>'|
% * |DIFF_CLASS =  
% ['<p>' INCORRECT ' %s class expected; %s class given.</p>']|
% * |DIFF_DIM = 
% ['<p>' INCORRECT ' Dimension Mismatch: %s expected; %s given.</p>']|
% * |DIFF_NUM_VALUE = 
% ['<p>' INCORRECT ' %g expected; %g given.</p>']|
% * |DIFF_STR_VALUE = 
% ['<p>' INCORRECT ' "%s" expected; "%s" given.</p>']|
% * |DIFF_CEL_VALUE = 
% ['<p>' INCORRECT ' %s expected at index (%s); %s given. There may be other differences.</p>']|
% * |DIFF_STC_VALUE = 
% ['<p>' INCORRECT ' %s expected in field "%s"; %s given. There may be other differences.</p>']|
% Each of these constants has flags for inserting the correct value and
% the received value.

function htmlFeedBack = generateFeedback(soln, stud)

end