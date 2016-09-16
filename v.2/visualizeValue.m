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
        % TODO: implement
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