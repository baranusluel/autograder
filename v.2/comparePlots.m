function plotComparisonResult = comparePlots(studentPlot, solutionPlot)
    fields = fieldnames(studentPlot.properties);
    plotComparisonResult = struct([]);
    for ndxField = 1:length(fields)
        field = fields{ndxField};
        plotComparisonResult.(field) = comparePlotProperties(studentPlot.properties.(field), solutionPlot.properties.(field));
    end
end

function isEqual = comparePlotProperties(studentProperty,solutionProperty)
    isEqual = true;
    if ~strcmp(class(studentProperty), class(solutionProperty))
        isEqual = false;
    elseif iscell(studentProperty)
        maxLength      = max(cellfun(@(x) numel(x), studentProperty));
        studentMatrix  = cell2mat(cellfun(@(x) cat(2, x, zeros(1, maxLength - length(x))),studentProperty , 'UniformOutput', false));
        solutionMatrix = cell2mat(cellfun(@(x) cat(2, x, zeros(1, maxLength - length(x))),solutionProperty, 'UniformOutput', false));
        for i = 1:size(studentMatrix,1)
            isEqual = isEqual && ismember(studentMatrix(i,:), solutionMatrix, 'rows');
        end
    else
        isEqual = isequal(studentProperty, solutionProperty);
    end
end