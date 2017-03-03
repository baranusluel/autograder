function factor = similarity(a, b)
ROUND_TO = 8; % number of decimal places to round to (helps eliminate floating-point errors when grading)
CLASS_MISMATCH_PENALTY = .8; % max credit possible as result of class mismatch (assuming function can determine a comparison between the values)
% initial check for exact equivalence
if isequaln(a, b) && isa(a, class(b))
    factor = 1;
    return;
end
% get input info
dimsA = size(a);
dimsB = size(b);
numelA = numel(a);
numelB = numel(b);

% are they the same class
if isa(a, class(b))
    % array comparison
    if isnumeric(a) || ischar(a)        
        % linearize, convert to double and round
        a = round(double(a(:)), ROUND_TO);
        b = round(double(b(:)), ROUND_TO);
        % same size
        if isequal(dimsA, dimsB)
            factor = 1 - pdist2(a, b, 'cosine');
            return;
        end
        
        % same number of elements
        if numelA == numelB
            sizeDiff = 1 - pdist2(dimsA, dimsB, 'cosine');
            factor = sizeDiff * (1 - pdist2(a(:), b(:), 'cosine'));
            return;
        end
        
        % not the same number of elements
        % compute Levenshtein distance between vectors
        factor = 1 - strdist(a, b) ./ max(numelA, numelB);
        return
    end
    
    % cell comparison
    if iscell(a)
        
        return
    end
    
    % struct comparison
    if isstruct(a)
        
        return
    end
    
    error('Unrecognized input class');
end

% a and b are different data types

% see if one is numeric and one is char
% if so, treat the chars as numbers and compute similarity
if (isnumeric(a) && ischar(b)) || (ischar(a) && isnumeric(b))
    factor = CLASS_MISMATCH_PENALTY * similarity(double(a), double(b));
    return
end

% if one is a cell array verson of the other
if iscell(a) && isequal(numelA, numelB) % implies that b is not a cell
    factor = CLASS_MISMATCH_PENALTY * similarity(a, num2cell(b));
    return;
elseif iscell(b) && isequal(numelA, numelB) % implies that a is not a cell
    factor = CLASS_MISMATCH_PENALTY * similarity(num2cell(a), b);
    return;
end
    
% if one is a scalar cell containing the other
if iscell(a) && numelA == 1
    factor = CLASS_MISMATCH_PENALTY * similarity(a{:}, b);
elseif iscell(b) && numelB == 1
    factor = CLASS_MISMATCH_PENALTY * similarity(a, b{:});
end
end
            