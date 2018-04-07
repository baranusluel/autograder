%% generateFeedback: Generate HTML feedback for primitives
%
% |generateFeedback| makes presentation-ready HTML that depicts how the 
% student's primitive result compares to the solution's primitive result.
%
% HTML = generateFeedback(STUD, SOLN) will generate HTML encoded feedback, 
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
% |generateFeedback| first checks each value's class. If they differ,
% a |DIFF_CLASS| is returned. Otherwise, |generateFeedback| checks to see
% if they are |isequaln|. If they are, |PASSING| is returned. The class
% types are checked for before equality because isequaln(double(1),uint8(1))
% returns true. Next, |generateFeedback| checks if the two inputs differ in
% size. If so, |DIFF_DIM| is returned. If not, |generateFeedback| then checks
% if the inputs are non-scalar (excluding char row vectors), and if so,
% recursively calls itself on the elements within the arrays. Otherwise,
% depending on the class and the guidelines below, a visualization of the
% difference between the given arguments is returned. The return value will
% always have the check mark (|PASSING|) or the red x (|INCORRECT|).
%
% `visualize` means the whole thing is printed out. So a visualized array
% means we actually print out the whole array.
% 
% Unless noted, following items only apply to primitives, where a primitive
% is any data type except cell or struct.
% 
% * Strings or character vectors are always visualized as long as they are
% less than 1,000 elements long
% * Vectors less than 50 elements are always visualized
% * Scalar primitives are always visualized
% * 2 Dimensional Arrays with less than 20 rows and less than 20 columns are visualized.
% * 3 or more dimensional arrays are not visualized
% * Scalar structures with less than 15 fields are visualized. Each field's
% value is visualized according to this same rule set
% * Structure arrays where the only difference is one of the structures is
% visualized. The only visualization is for the single structure, and the
% index of that structure is noted.
% * Structure arrays where there is more than one difference are not visualized.
% * Scalar cell arrays with less than 50 elements are visualized - it's
% contents are visualized according to this rule set
% * Cell arrays less than 5 rows and less than 5 columns are visualized,
% with contents being visualized according to this rule set.
% * Any case not covered here isn't visualized.
%
% Any case that is not visualized is instead `differenced`.
% differencing means you take the first 5 differences between the two
% variables, and visualize them. Then, you write that there were n-5 more
% differences, where n is the total number of differences.
%
%%% Exceptions
%
% generateFeedback is guaranteed to never throw an exception, 
% as long as two arguments are given.
%
%%% Unit Tests
%
%   S = [];
%   P = [];
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = NaN;
%   P = NaN;
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = 1;
%   P = S;
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<span class="fas fa-check"></span>'
%
%   S = 'Hello world';
%   P = 1;
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> char class expected; double class given.</p>'
%
%   S = uint8(1);
%   P = double(1);
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> uint8 class expected; double class given.</p>'
%
%   S = 1;
%   P = 2;
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> 1 expected; 2 given.</p>'
%
%   S = "Hello World"
%   P = "Goodbye World"
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> "Hello World" expected; "Goodbye World" given.</p>'
%
%   S = true;
%   P = false;
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> true expected; false given.</p>'
%
%   S = [1 2 3];
%   P = [1; 2; 3];
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> Dimension Mismatch: Expected 1x3; 3x1 given.</p>'
%
%   S = {1, 2, 3};
%   P = {1, 3, 2};
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> At index (1x2): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 2 expected; 3 given.</p></div></p>
%            <p><span class="fas fa-times"></span> At index (1x3): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 3 expected; 2 given.</p></div></p>'
%
%   S = [1, 2, 3];
%   P = [1, 3, 2];
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> At index (1x2): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 2 expected; 3 given.</p></div></p>
%            <p><span class="fas fa-times"></span> At index (1x3): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 3 expected; 2 given.</p></div></p>'
%
%   S = struct('hello', 1, 'world', {1, 2, 3});
%   P = struct('hello', 2, 'world', {3, 2, 1});
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> At index (1x1): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> In field "hello": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 1 expected; 2 given.</p></div></p><p><span class="fas fa-times"></span> In field "world": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 1 expected; 3 given.</p></div></p></div></p>
%            <p><span class="fas fa-times"></span> At index (1x2): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> In field "hello": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 1 expected; 2 given.</p></div></p></div></p>
%            <p><span class="fas fa-times"></span> At index (1x3): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> In field "hello": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 1 expected; 2 given.</p></div></p><p><span class="fas fa-times"></span> In field "world": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 3 expected; 1 given.</p></div></p></div></p>'
%
%   S = struct('a', 1, 'b', 0);
%   P = struct('a', 2, 'c', 10);
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> a,b fields expected; a,c fields given.</p>'
%
%   S = {1, struct('a',1)};
%   P = {{1}, struct('a',2)};
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span> At index (1x1): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> double class expected; cell class given.</p></div></p>
%            <p><span class="fas fa-times"></span> At index (1x2): <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> In field "a": <div style="margin-left: 10px;"><p><span class="fas fa-times"></span> 1 expected; 2 given.</p></div></p></div></p>'
%
%   S is a handle
%   P is a different handle
%   HTML = generateFeedback(P, S);
%
%   HTML -> '<p><span class="fas fa-times"></span>(Disp of S)<br>expected;<br>(Disp of P)<br>given.</p>'
%
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
% * |DIFF_BOOL_VALUE = 
% ['<p>' INCORRECT ' %s expected; %s given.</p>']|
% * |DIFF_MISC_VALUE = 
% ['<p>' INCORRECT ' %s<br>expected;<br>%s<br>given.</p>']|
% * |DIFF_ARR_VALUE = 
% ['<p>' INCORRECT ' At index (%s): %s</p>']|
% * |DIFF_STC_VALUE = 
% ['<p>' INCORRECT ' In field "%s"; %s</p>']|
% * |DIFF_STC_FIELD =
% ['<p>' INCORRECT ' %s fields expected; %s fields given.</p>']|
% * |INDENT_BLOCK = '<div style="margin-left: 10px;">%s</div>'|
% Each of these constants has flags for inserting the correct value and
% the received value.

function htmlFeedback = generateFeedback(stud, soln)
    PASSING = '<span class="fas fa-check></span>';
    INCORRECT = '<span class="fas fa-times"></span>';
    DIFF_CLASS = ['<p>' INCORRECT ' %s class expected; %s class given.</p>'];
    DIFF_DIM = ['<p>' INCORRECT ' Dimension Mismatch: %s expected; %s given.</p>'];
    DIFF_NUM_VALUE = ['<p>' INCORRECT ' %g expected; %g given.</p>'];
    DIFF_STR_VALUE = ['<p>' INCORRECT ' "%s" expected; "%s" given.</p>'];
    DIFF_BOOL_VALUE = ['<p>' INCORRECT ' %s expected; %s given.</p>'];
    DIFF_MISC_VALUE = ['<p>' INCORRECT ' %s<br>expected;<br>%s<br>given.</p>'];
    DIFF_ARR_VALUE = ['<p>' INCORRECT ' At index (%s): %s</p>'];
    DIFF_STC_VALUE = ['<p>' INCORRECT ' In field "%s": %s</p>'];
    DIFF_STC_FIELD = ['<p>' INCORRECT ' %s fields expected; %s fields given.</p>'];
    INDENT_BLOCK = '<div style="margin-left: 10px;">%s</div>';
    
    % check if different class
    if ~isequal(class(soln), class(stud))
        htmlFeedback = sprintf(DIFF_CLASS, class(soln), class(stud));
        
    % check if equal
    % do after class check because isequaln(uint8(1),double(1)) is true
    elseif isequaln(soln, stud)
        htmlFeedback = PASSING;
        
    % check if same size
    elseif ~isequal(size(soln), size(stud))
        soln_size = strrep(num2str(size(soln)), '  ', 'x');
        stud_size = strrep(num2str(size(stud)), '  ', 'x');
        htmlFeedback = sprintf(DIFF_DIM, soln_size, stud_size);
        
    % check if not scalar (but excluding row vector of chars, i.e. strings)
    % if so, compare elements in the vector/array individually
    % because visual diff code for primitives expects scalars (apart from
    % row vectors of chars, which are easy to display)
    elseif numel(stud) > 1 && ...
        ~(ischar(stud) && ndims(stud) == 2 && size(stud, 1) == 1)
        htmlFeedback = [];
        % iterate over indices, call generateFeedback recursively to find
        % differences at each position
        % use linear indexing because number of dimensions is unknown;
        % subscripts are reconstructed from index below
        for i = 1:numel(stud)
            stud_inner = stud(i);
            soln_inner = soln(i);
            feedback_inner = generateFeedback(stud_inner, soln_inner);
            % if found a difference
            if ~isequal(feedback_inner, PASSING)
                % cell array to store subscript indices for each dimension,
                % so that we can get all of ind2sub's vararg outputs
                % without knowing number of dimensions beforehand
                idx = cell(1,ndims(stud));
                [idx{:}] = ind2sub(size(stud),i);
                % convert indices to x separated string
                idx = strrep(num2str(cell2mat(idx)), '  ', 'x');
                % indent feedback_inner for improved readability
                feedback_inner = sprintf(INDENT_BLOCK, feedback_inner);
                % add to htmlFeedback
                msg = sprintf(DIFF_ARR_VALUE, idx, feedback_inner);
                if isempty(htmlFeedback)
                    htmlFeedback = msg;
                else
                    htmlFeedback = [htmlFeedback msg];
                end
            end
        end
        
    % class-specific visual diffs
    elseif isfloat(stud) || isinteger(stud)
        htmlFeedback = sprintf(DIFF_NUM_VALUE, soln, stud);
        
    elseif ischar(stud) || isstring(stud)
        htmlFeedback = sprintf(DIFF_STR_VALUE, soln, stud);
        
    elseif isstruct(stud)
        % check if both structs have same fields
        soln_fields = fieldnames(soln);
        stud_fields = fieldnames(stud);
        if ~isequal(sort(soln_fields), sort(stud_fields))
            htmlFeedback = sprintf(DIFF_STC_FIELD, strjoin(soln_fields, ','), ...
                strjoin(stud_fields, ','));
        else
            htmlFeedback = [];
            % iterate over fields, call generateFeedback recursively on
            % values to find differences, even if nested
            for i = 1:length(stud_fields)
                field = stud_fields{i};
                stud_inner = stud.(field);
                soln_inner = soln.(field);
                feedback_inner = generateFeedback(stud_inner, soln_inner);
                % if found a difference
                if ~isequal(feedback_inner, PASSING)
                    % indent feedback_inner for improved readability
                    feedback_inner = sprintf(INDENT_BLOCK, feedback_inner);
                    % add to htmlFeedback
                    msg = sprintf(DIFF_STC_VALUE, field, feedback_inner);
                    if isempty(htmlFeedback)
                        htmlFeedback = msg;
                    else
                        htmlFeedback = [htmlFeedback msg];
                    end
                end
            end
        end
        
    elseif iscell(stud)
        htmlFeedback = generateFeedback(stud{1}, soln{1});
        
    elseif islogical(stud)
        bools = {'false', 'true'};
        htmlFeedback = sprintf(DIFF_BOOL_VALUE, bools{soln+1}, bools{stud+1});
        
    % case we didn't account for -> fallback message
    else
        htmlFeedback = sprintf(DIFF_MISC_VALUE, ...
            matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(soln), ...
            matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(stud));
    end
end