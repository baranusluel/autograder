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
% |visualize| means the whole thing is printed out. So a |visualized| array
% means we actually print out the whole array.
% 
% Unless noted, following items only apply to primitives, where a primitive
% is any data type except cell or struct.
% 
% * Scalar primitives are always |visualized|.
% * Strings or character vectors are always |visualized| as long as they are
% less than 1,000 elements long.
% * Vectors of primitives less than 50 elements are always |visualized|.
% * 2 dimensional arrays of primitives with less than 20 rows and less than
% 20 columns are |visualized|.
% * 3 or more dimensional arrays are not |visualized|.
% * Scalar structures with less than 15 fields, with primitive values in
% all fields, are |visualized|.
% * Structure arrays where the only difference is one of the structures is
% |visualized| (if rule above is met). The only visualization is for the
% single structure, and the index of that structure is noted.
% * Structure arrays with more than one different structure are
% not |visualized|.
% * Scalar cells are visualized - their contents are |visualized| according
% to the these rules.
% * Cell arrays with less than 5 rows and less than 5 columns, and
% primitives inside each cell, are |visualized|.
% * Any case not covered here isn't |visualized|.
%
% Any case that is not |visualized| is instead |differenced|.
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
% (See below for complete list).
%
% Each of these constants has flags for inserting the correct value and
% the received value.

%#ok<*AGROW>
function htmlFeedback = generateFeedback(stud, soln)
    PASSING = '<span class="fas fa-check"></span>';
    INCORRECT = '<span class="fas fa-times"></span>';
    START_SPAN = '<span class="variable-value">';
    END_SPAN = '</span>';
    DIFF_CLASS = ['<p>' INCORRECT ' ' START_SPAN '%s' END_SPAN ' class expected; ' START_SPAN '%s' END_SPAN ' class given.</p>'];
    DIFF_DIM = ['<p>' INCORRECT ' Dimension Mismatch: ' START_SPAN '%s' END_SPAN ' expected; ' START_SPAN '%s' END_SPAN ' given.</p>'];
    TABLE = ['<p>' INCORRECT ' Value Incorrect:</p><div class="flex-container"><div class="flex-element"><p>Expected:</p>' START_SPAN '%s' END_SPAN '</div>' ...
        '<div class="flex-element"><p>Given:</p>' START_SPAN '%s' END_SPAN '</div></div>'];
    DIFF_VALUE = ['<p>' START_SPAN '%s' END_SPAN ' expected; ' START_SPAN '%s' END_SPAN ' given.</p>'];
    DIFF_ARR_VALUE = ['<p>At index (' START_SPAN '%s' END_SPAN '): ' START_SPAN '%s' END_SPAN '</p>'];
    DIFF_STC_VALUE = ['<p>In field "' START_SPAN '%s' END_SPAN '": ' START_SPAN '%s' END_SPAN '</p>'];
    DIFF_STC_FIELD = ['<p>' START_SPAN '%s' END_SPAN ' fields expected; ' START_SPAN '%s' END_SPAN ' fields given.</p>'];
    INDENT_BLOCK = '<div style="margin-left: 10px;">%s</div>';
    DIFF_STC = ['<p>struct with fields:</p>' INDENT_BLOCK];
    DIFF_CELL = ['<p>In cell: ' START_SPAN '%s' END_SPAN '</p>'];
    NUM_DIFFS = 5;
    MAX_STR = 1000;
    MAX_VEC_COLS = 50;
    MAX_ARR_SIZE = 20;
    MAX_FIELDS = 15;
    MAX_CELL_SIZE = 5;
    constants = containers.Map({'PASSING', 'INCORRECT', 'DIFF_CLASS', 'DIFF_DIM', 'TABLE', 'DIFF_VALUE', ...
        'DIFF_ARR_VALUE', 'DIFF_STC_VALUE', 'DIFF_STC_FIELD', 'INDENT_BLOCK', 'DIFF_STC', 'DIFF_CELL', ...
        'NUM_DIFFS', 'MAX_STR', 'MAX_VEC_COLS', 'MAX_ARR_SIZE', 'MAX_FIELDS', 'MAX_CELL_SIZE'}, ...
        {PASSING, INCORRECT, DIFF_CLASS, DIFF_DIM, TABLE, DIFF_VALUE, ...
        DIFF_ARR_VALUE, DIFF_STC_VALUE, DIFF_STC_FIELD, INDENT_BLOCK, DIFF_STC, DIFF_CELL, ...
        NUM_DIFFS, MAX_STR, MAX_VEC_COLS, MAX_ARR_SIZE, MAX_FIELDS, MAX_CELL_SIZE});
    
    % check if different class
    if ~strcmp(class(soln), class(stud))
        htmlFeedback = sprintf(DIFF_CLASS, class(soln), class(stud));
        return
    end
    
    % check if equal
    % do after class check because isequaln(uint8(1),double(1)) is true
    if isequaln(soln, stud)
        htmlFeedback = PASSING;
        return
    end
    
    % check if same size
    if ~isequal(size(soln), size(stud))
        solnSize = strrep(num2str(size(soln)), '  ', 'x');
        studSize = strrep(num2str(size(stud)), '  ', 'x');
        htmlFeedback = sprintf(DIFF_DIM, solnSize, studSize);
        return
    end
        
    % check if char vector/string and meets visualization rule
    if (ischar(stud) && ismatrix(stud) && all(size(stud) <= [1 MAX_STR])) ...
        || (isstring(stud) && numel(strlength(stud)) == 1 && strlength(stud) <= MAX_STR)
        htmlFeedback = sprintf(TABLE, visualizePrimitive(soln), visualizePrimitive(stud));
        return
    end
    
    % check if is a scalar primitive
    if isscalar(stud) && isPrimitive(stud)
        htmlFeedback = sprintf(TABLE, visualizePrimitive(soln), visualizePrimitive(stud));
        return
    end
    
    % check if is a primitive vector of length less than 50 or array of
    % size less than 20x20
    if isPrimitive(stud) && ismatrix(stud)
        if all(size(stud) <= [1 MAX_VEC_COLS])
            htmlFeedback = sprintf(TABLE, visualizeVector(soln), visualizeVector(stud));
            return
        end
        if all(size(stud) <= [MAX_ARR_SIZE MAX_ARR_SIZE])
            htmlFeedback = sprintf(TABLE, visualizeArray(soln), visualizeArray(stud));
            return
        end
    end
    
    % check if is a structure
    if isstruct(stud)
        solnFields = fieldnames(soln);
        studFields = fieldnames(stud);
        % if different fields
        if ~isequal(sort(solnFields), sort(studFields))
            htmlFeedback = sprintf(DIFF_STC_FIELD, strjoin(solnFields, ', '), ...
                strjoin(studFields, ', '));
            return
        end
        % indexes (linearized) of different structures in struct array
        diffs = false(1, numel(stud));
        for i = 1:numel(stud)
            if ~isequal(stud(i), soln(i))
                diffs(i) = true;
            end
        end
        diffs = find(diffs);
        % if only one difference and fewer than 15 fields
        if length(diffs) == 1 && numel(studFields) <= MAX_FIELDS
            % check if all fields' values are primitives
            allPrimitives = true;
            % cell array has to be transposed for the for-each loop
            for field = solnFields'
                studValIsPrimitive = isPrimitive(stud(diffs).(field{1}));
                solnValIsPrimitive = isPrimitive(soln(diffs).(field{1}));
                if ~studValIsPrimitive || ~solnValIsPrimitive
                    allPrimitives = false;
                    break
                end
            end
            % if visualizable
            if allPrimitives
                htmlFeedback = sprintf(TABLE, visualizeStruct(soln(diffs), constants), ...
                    visualizeStruct(stud(diffs), constants));
                if ~isscalar(stud)
                    htmlFeedback = sprintf(DIFF_ARR_VALUE, ...
                        linear2Subscript(diffs, size(stud)), htmlFeedback);
                end
                return
            end
        end
    end
    
    if iscell(stud)
        if isscalar(stud)
            htmlFeedback = sprintf(DIFF_CELL, generateFeedback(stud{1},soln{1}));
            return
        end
        if ismatrix(stud) && all(size(stud) <= [MAX_CELL_SIZE MAX_CELL_SIZE])
            % check if all cells' contents are primitives
            allPrimitives = true;
            for i = 1:numel(stud)
                studValIsPrimitive = isPrimitive(stud{i});
                solnValIsPrimitive = isPrimitive(soln{i});
                if ~studValIsPrimitive || ~solnValIsPrimitive
                    allPrimitives = false;
                    break
                end
            end
            if allPrimitives
                htmlFeedback = sprintf(TABLE, visualizeArray(soln, true), ...
                    visualizeArray(stud, true));
                return
            end
        end
    end
        
    htmlFeedback = findDifference(stud, soln, constants, true);
end
    

%% Generate string visualization of a primitive
function str = visualizePrimitive(val)
    if (ischar(val) && ismatrix(val) && size(val, 1) <= 1) ...
        || (isstring(val) && numel(strlength(val)) == 1)
        str = strcat('"', val, '"');
    elseif isfloat(val) || isinteger(val)
        str = sprintf('%g', val);
    elseif islogical(val)
        bools = {'false', 'true'};
        str = bools{val+1};
    end
end

%% Generate string/HTML visualization of an array
function HTML = visualizeArray(val, isCell)
    if nargin == 1
        isCell = false;
    end
    [rows, cols] = size(val);
    HTML = '<table class="table">';
    for r = 1:rows
        HTML = [HTML '<tr>'];
        for c = 1:cols
            if isCell
                HTML = [HTML '<td>{' visualizePrimitive(val{r,c}) '}</td>'];
            else
                HTML = [HTML '<td>' visualizePrimitive(val(r,c)) '</td>'];
            end
        end
        HTML = [HTML '</tr>'];
    end
    HTML = [HTML '</table>'];
end

%% Generate string/HTML visualization of a primitive vector
function HTML = visualizeVector(val)
    strings = cell(1,length(val));
    for i = 1:length(val)
        strings{i} = visualizePrimitive(val(i));
    end
    HTML = ['[' strjoin(strings, ', ') ']'];
end


%% Generate string/HTML visualization of a structure
function HTML = visualizeStruct(val, constants)
    fields = sort(fieldnames(val));
    lines = cell(1, length(fields));
    for i = 1:length(fields)
        lines{i} = [fields{i} ': ' visualizePrimitive(val.(fields{i}))];
    end
    HTML = sprintf(constants('DIFF_STC'), strjoin(lines, '<br>'));
end

%% Convert linearized index to subscript indices
function idx = linear2Subscript(linearIndx, arr)
    idx = cell(1, ndims(arr));
    [idx{:}] = ind2sub(size(arr), linearIndx);
    % convert indices to x separated string
    idx = strrep(num2str(cell2mat(idx)), '  ', ',');
end

%% Check if value is a primitive
function isPrim = isPrimitive(val)
    isPrim = isfloat(val) || isinteger(val) || ischar(val) ...
                || isstring(val) || islogical(val);
end

%% 'Difference' the student and solution values
function htmlFeedback = findDifference(stud, soln, constants, ~)
    persistent diffNum
    if nargin == 4
        diffNum = 0;
    elseif diffNum >= constants('NUM_DIFFS')
        htmlFeedback = [];
        return
    end
    
    % check if different class
    if ~isequal(class(soln), class(stud))
        htmlFeedback = sprintf(constants('DIFF_CLASS'), class(soln), class(stud));
        diffNum = diffNum + 1;

    % check if equal
    % do after class check because isequaln(uint8(1),double(1)) is true
    elseif isequaln(soln, stud)
        htmlFeedback = constants('PASSING');

    % check if same size
    elseif ~isequal(size(soln), size(stud))
        solnSize = strrep(num2str(size(soln)), '  ', 'x');
        studSize = strrep(num2str(size(stud)), '  ', 'x');
        htmlFeedback = sprintf(constants('DIFF_DIM'), solnSize, studSize);
        diffNum = diffNum + 1;

    % check if not scalar (but excluding row vector of chars, i.e. strings)
    % if so, compare elements in the vector/array individually
    % because visual diff code for primitives expects scalars (apart from
    % row vectors of chars, which are easy to display)
    elseif numel(stud) > 1 && ...
        ~(ischar(stud) && ismatrix(stud) && size(stud, 1) == 1)
        htmlFeedback = [];
        % iterate over indices, call findDifference recursively to find
        % differences at each position
        % use linear indexing because number of dimensions is unknown;
        % subscripts are reconstructed from index below
        for i = 1:numel(stud)
            if diffNum >= constants('NUM_DIFFS')
                break;
            end
            stud_inner = stud(i);
            soln_inner = soln(i);
            feedback_inner = findDifference(stud_inner, soln_inner, constants);
            % if found a difference
            if ~isequal(feedback_inner, constants('PASSING'))
                idx = linear2Subscript(i, stud);
                % indent feedback_inner for improved readability
                feedback_inner = sprintf(constants('INDENT_BLOCK'), feedback_inner);
                % add to htmlFeedback
                msg = sprintf(constants('DIFF_ARR_VALUE'), idx, feedback_inner);
                if isempty(htmlFeedback)
                    htmlFeedback = msg;
                else
                    htmlFeedback = [htmlFeedback msg];
                end
            end
        end

    % class-specific visual diffs
    elseif isfloat(stud) || isinteger(stud)
        htmlFeedback = sprintf(constants('DIFF_VALUE'), visualizePrimitive(soln), ...
            visualizePrimitive(stud));
        diffNum = diffNum + 1;

    elseif ischar(stud) || isstring(stud)
        htmlFeedback = sprintf(constants('DIFF_VALUE'), visualizePrimitive(soln), ...
            visualizePrimitive(stud));
        diffNum = diffNum + 1;

    elseif isstruct(stud)
        % check if both structs have same fields
        solnFields = fieldnames(soln);
        studFields = fieldnames(stud);
        if ~isequal(sort(solnFields), sort(studFields))
            htmlFeedback = sprintf(constants('DIFF_STC_FIELD'), strjoin(solnFields, ','), ...
                strjoin(studFields, ','));
            diffNum = diffNum + 1;
        else
            htmlFeedback = [];
            % iterate over fields, call findDifference recursively on
            % values to find differences, even if nested
            for i = 1:length(studFields)
                if diffNum >= constants('NUM_DIFFS')
                    break;
                end
                field = studFields{i};
                stud_inner = stud.(field);
                soln_inner = soln.(field);
                feedback_inner = findDifference(stud_inner, soln_inner, constants);
                % if found a difference
                if ~isequal(feedback_inner, constants('PASSING'))
                    % indent feedback_inner for improved readability
                    feedback_inner = sprintf(constants('INDENT_BLOCK'), feedback_inner);
                    % add to htmlFeedback
                    msg = sprintf(constants('DIFF_STC_VALUE'), field, feedback_inner);
                    if isempty(htmlFeedback)
                        htmlFeedback = msg;
                    else
                        htmlFeedback = [htmlFeedback msg];
                    end
                end
            end
        end

    elseif iscell(stud)
        htmlFeedback = findDifference(stud{1}, soln{1}, constants);

    elseif islogical(stud)
        bools = {'false', 'true'};
        htmlFeedback = sprintf(constants('DIFF_VALUE'), visualizePrimitive(bools{soln+1}), ...
            visualizePrimitive(bools{stud+1}));
        diffNum = diffNum + 1;

    % case we didn't account for -> fallback message
    else
        htmlFeedback = sprintf(constants('TABLE'), ...
            matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(soln), ...
            matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(stud));
        diffNum = diffNum + 1;
    end
end