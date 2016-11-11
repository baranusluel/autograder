%% visualizeValue Visualizes different data types
%
%   formattedValue = visualizeValue(value)
%
%   Inputs:
%       value (any)
%           - the value to visualize
%
%   Output:
%       formattedValue (any)
%           - the value formatted to visualize
%
%   Description:
%       Gets feedback for a student for a single problem
function formattedValue = visualizeValue(value)
    numberOfDimensions = ndims(value);
    dimensions = {};
    [dimensions{1:numberOfDimensions}] = size(value);
    r = dimensions{1};
    c = dimensions{2};
    if isnumeric(value)
        % if empty
        if isempty(value)
            formattedValue = '[]';
        % if scalar
        elseif length(value) == 1
            % if is integer
            if floor(value) == value
                formattedValue = sprintf('%d', value);
            else
                formattedValue = sprintf('%.4f', value);
            end
        % if vector or 2D array
        elseif numberOfDimensions == 2
            formattedValue = mat2str(value);
        % if 3D array
        else
            formattedValue = 'cat(3';
            for ndx = 1:dimensions{3}
                formattedValue = [formattedValue, ',', mat2str(value(:, :, ndx))]; %#ok
            end
            formattedValue = [formattedValue, ')'];
        end
    elseif ischar(value)
        % if empty
        if isempty(value)
            formattedValue = '''''';
        % if string (row vector)
        elseif r == 1
            % replace apostrophes
            temp_value = strrep(value, '''', '''''');
            formattedValue = sprintf('''%s''', temp_value);
        % if column vector or 2D array
        elseif numberOfDimensions == 2
            formattedValue = format2DCharArray(value, r);
        % if 3D array
        else
            formattedValue = 'cat(3';
            for ndx = 1:dimensions{3}
                formattedValue = [formattedValue, ',', format2DCharArray(value(:, :, ndx), r)]; %#ok
            end
            formattedValue = [formattedValue, ')'];
        end
    elseif islogical(value)
        % if empty
        if isempty(value)
            formattedValue = 'logical([])';
        % if single value
        elseif length(value) == 1
            formattedValue = log2str(value);
        % if 2D array
        elseif numberOfDimensions == 2
            formattedValue = format2DLogicalArray(value, r, c);
        % if 3D array
        else
            formattedValue = 'cat(3';
            for ndx = 1:dimensions{3}
                formattedValue = [formattedValue, ',', format2DLogicalArray(value(:, :, ndx), r, c)]; %#ok
            end
            formattedValue = [formattedValue, ')'];
        end
    elseif iscell(value)
        % if empty
        if isempty(value)
            formattedValue = '{}';
        % if 2D array
        elseif numberOfDimensions == 2
            formattedValue = '{';
            for row_ndx = 1:r
                for col_ndx = 1:c
                    formattedValue = [formattedValue, visualizeValue(value{row_ndx, col_ndx}), ',']; %#ok
                end
                formattedValue(end) = ';';
            end
            formattedValue(end) = '}';
        end
    elseif isstruct(value)
        % basically, for each of the structures in the possible array, get
        % the MATLAB display of it (Because it is already displayed by
        % MATLAB quite nicely I believe!)
        % get the size and summarize our structure:
        if numel(value) == 1
            strTemp = 'element';
        else
            strTemp = 'elements';
        end
        strStart = sprintf('Structure of size [%s] (%d %s):<br>Fields:', num2str(size(value)), numel(value), strTemp);
        strFields = strjoin(fieldnames(value), '<br>');
        strStart = [strStart '<br>' strFields '<br>'];
        % prep for a cellfun:
        stcValue = value(:);
        stcValue = num2cell(stcValue);
        % since MATLAB actually does a great job of visualizing a
        % structure, we're just going to evaluate (disp(stc)) and save the
        % results!
        cellReps = cellfun(@(stc)(evalc('disp(stc);'))', stcValue, 'uni', false);
        % find the last useful size.
        vecSize = size(value);
        % make a cell array to hold all of the correct indices:
        cellInds = cell(1, numel(vecSize));
        % capture ALL of the relevant indices, and format them correctly
        % (we need to do a num2str on all the inner cell arrays; else
        % strjoin won't work!)
        [cellInds{:}] = cellfun(@(ind)(ind2sub(size(value), ind)), num2cell(1:numel(value)), 'uni', false);
        % create our formatted indices
        %   first, we reorganize our cell array of indices such that we
        %   numel(value) on the OUTSIDE, and numel(vecSize) on the INSIDE!
        cellInds = cellfun(@(r)(cellfun(@(ind)(cellInds{ind}(r)), num2cell(1:numel(vecSize)), 'uni', false)), num2cell(1:numel(value)), 'uni', false);
        %   Now, we need to get each element of cellInds (which is now of
        %   size 1 row, numel(value) columns) to hold all of its
        %   corresponding elements. Each inner cell array only holds a cell
        %   array of 1 (and EXACTLY 1) integer, which is the index for that
        %   dimension - that's why each cell array inside of cellInds is of
        %   size numel(vecSize).
        cellInds = cellfun(@(c1)(cellfun(@(int)(num2str(int{1})), c1, 'uni', false)), cellInds, 'uni', false);
        %   finally, concatenate all of the indices back together and place
        %   the result into each of the corresponding indices!
        cellInds = cellfun(@(d1)(strjoin(d1, ', ')), cellInds, 'uni', false);
        % create our string. Concatenate the index of the current structure
        % with the display of the structure.
        strVal = cellfun(@(strInd, str2)(['struct(' strInd '):' '<br>' str2']), cellInds', cellReps, 'uni', false);
        % join everything together. Since the returns are already there we
        % don't need to join with a carriage return!
        strVal = strjoin(strVal, '');
        % get rid of the last extra returns:
        strVal = strVal(1:end-1);
        % add our beginning string and return the output:
        formattedValue = [strStart '<br>' strVal];
    end
end

function formattedValue = format2DCharArray(value, r)
    formattedValue = '[';
    for ndx = 1:r
        % replace apostrophes
        temp_value = strrep(value(ndx, :), '''', '''''');
        formattedValue = sprintf('%s''%s'';', formattedValue, temp_value);
    end
    formattedValue(end) = ']';
end

function str = log2str(log)
    if log
        str = 'true';
    else
        str = 'false';
    end
end

function formattedValue = format2DLogicalArray(value, r, c)
    formattedValue = '[';
    for row_ndx = 1:r
        for col_ndx = 1:c
            formattedValue = [formattedValue, log2str(value(row_ndx, col_ndx)), ',']; %#ok
        end
        formattedValue(end) = ';';
    end
    formattedValue(end) = ']';
end