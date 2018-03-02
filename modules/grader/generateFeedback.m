%% generateFeedback: Generate HTML feedback for primitives
%
% generateFeedback makes presentation-ready HTML that depicts how the 
% student's primitive result compares to the solution's primitive result.
%
% HTML = generateFeedback(STUD, SOLN) will generate HTML encoded feedback, 
% given the student's result and the solution's result. Both must be given, 
% but empty is a valid result.
%
%%% Remarks
%
% generateFeedback deals only with "primitive" values. This means 
% the type of the given values must be one of the following:
%
% * double
% * single
% * uint8, uint16, uint32, uint64
% * int8, int16, int32, int64
% * char
% * string
% * cell
% * struct
% * logical
%
%
% Note that NaN is considered equal to NaN; ie, NaN == NaN = true.
% This is different from isequal, and instead follows isequaln.
%
%%% Exceptions
%
% generateFeedback is guarunteed to never throw an exception, 
% as long as two arguments are given.
%
%%% Unit Tests
%
%	S = [];
%	N = [];
%	HTML = generateFeedback(S, N);
%
%	HTML -> '<span class="fas fa-check"></span>'
%
%	S = 